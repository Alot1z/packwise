#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────────────────────
# PackWise — unsigned IPA build (reproducible, sideload-ready)
#
# Produces:  ios/build/PackWise-unsigned.ipa  (+ .sha256)
#
# Pipeline (same logic as .github/workflows/ios.yml and .gitea/workflows/ios.yml):
#   1. xcodegen generate
#   2. xcodebuild build  -sdk iphoneos -destination "generic/platform=iOS"
#      (device binary — NOT simulator; this is the single most common cause of
#       "Failed to map …/PackWise: Bad file descriptor" on sideloaders)
#   3. Validate the main executable exists, is non-empty, is arm64 Mach-O,
#      and carries the iOS device platform (LC_BUILD_VERSION platform 2).
#   4. Strip anything that does not belong in a shipped app:
#      _CodeSignature, PlugIns/*.xctest (test injection), XCTest frameworks.
#   5. Stage Payload/PackWise.app → ditto (macOS) or zip → .ipa
#   6. Strict validation: the .ipa MUST contain Payload/PackWise.app/PackWise
#      and Info.plist, otherwise the job fails loudly (never publish garbage).
# ─────────────────────────────────────────────────────────────────────────────
set -euo pipefail
cd "$(dirname "$0")"

BUILD=build
APP_NAME=PackWise
EXEC_NAME=PackWise
OUT_IPA="$BUILD/PackWise-unsigned.ipa"

if ! command -v xcodegen >/dev/null 2>&1; then
  echo "xcodegen not found. Install: brew install xcodegen" >&2
  exit 1
fi

echo "→ 1/6 Generating Xcode project..."
xcodegen generate

echo "→ 2/6 Building device app (iphoneos, arm64, no signing)..."
rm -rf "$BUILD/DerivedData" "$BUILD/Payload" "$OUT_IPA" "$BUILD/PackWise.xcarchive"
xcodebuild build \
  -project PackWise.xcodeproj \
  -scheme PackWise \
  -configuration Release \
  -sdk iphoneos \
  -destination "generic/platform=iOS" \
  -derivedDataPath "$BUILD/DerivedData" \
  ONLY_ACTIVE_ARCH=NO \
  ARCHS="arm64" \
  CODE_SIGNING_ALLOWED=NO \
  CODE_SIGNING_REQUIRED=NO \
  CODE_SIGN_IDENTITY="" \
  -skipPackagePluginValidation -skipMacroValidation 2>&1 | tee "$BUILD/build.log" | tail -n 40
if [ "${PIPESTATUS[0]}" != "0" ]; then
  echo "❌ xcodebuild build failed — see $BUILD/build.log" >&2
  exit 1
fi

APP=""
for candidate in \
  "$BUILD/DerivedData/Build/Products/Release-iphoneos/$APP_NAME.app" \
  "$BUILD/DerivedData/Build/Products/Release/$APP_NAME.app"; do
  if [ -f "$candidate/Info.plist" ]; then APP="$candidate"; break; fi
done
if [ -z "$APP" ]; then
  APP=$(find "$BUILD/DerivedData" -name "$APP_NAME.app" -type d 2>/dev/null | grep -v -E "\.xctest" | head -n1 || true)
fi
if [ -z "$APP" ] || [ ! -d "$APP" ]; then
  echo "❌ No $APP_NAME.app produced. Diagnostics:" >&2
  find "$BUILD" -type d -maxdepth 6 2>&1 | head -n 60 || true
  exit 1
fi
echo "✓ App bundle: $APP"

EXEC="$APP/$EXEC_NAME"
echo "→ 3/6 Validating main executable..."
if [ ! -f "$EXEC" ]; then
  echo "❌ Main executable MISSING: $EXEC" >&2
  echo "   This is the 'Bad file descriptor' sideload failure — never publish an IPA without its binary." >&2
  ls -la "$APP" >&2 || true
  exit 1
fi
if [ ! -s "$EXEC" ]; then
  echo "❌ Main executable is EMPTY (0 bytes): $EXEC" >&2
  exit 1
fi
chmod +x "$EXEC"

# Mach-O architecture check — must be a real device arm64 binary.
if command -v file >/dev/null 2>&1; then
  FILE_OUT=$(file "$EXEC")
  echo "   $FILE_OUT"
  case "$FILE_OUT" in
    *"arm64"*) : ;;
    *) echo "❌ Executable is not arm64 — simulator/wrong-arch build. $FILE_OUT" >&2; exit 1 ;;
  esac
fi

# Platform check via LC_BUILD_VERSION (2 = iOS device, 7 = iOS Simulator).
if command -v otool >/dev/null 2>&1; then
  PLATFORM=$(otool -l "$EXEC" 2>/dev/null | grep -A5 "LC_BUILD_VERSION" | grep -m1 "platform" | awk '{print $2}')
  echo "   LC_BUILD_VERSION platform=$PLATFORM (2=iOS device, 7=simulator)"
  if [ "$PLATFORM" = "7" ]; then
    echo "❌ Simulator binary — cannot run on a physical iPhone. Rebuild with -sdk iphoneos." >&2
    exit 1
  fi
  if [ -n "$PLATFORM" ] && [ "$PLATFORM" != "2" ]; then
    echo "⚠️ Unexpected platform $PLATFORM — expected 2 (iOS device)." >&2
  fi
fi

# Defensive: drop any non-arm64 slices (x86_64 simulator leftovers).
if command -v lipo >/dev/null 2>&1 && lipo -info "$EXEC" 2>/dev/null | grep -q "x86_64"; then
  echo "   → Stripping non-arm64 slices (lipo -thin arm64)"
  lipo -thin arm64 "$EXEC" -output "$EXEC.tmp" && mv "$EXEC.tmp" "$EXEC"
fi

echo "→ 4/6 Staging Payload/PackWise.app (stripping test injection)..."
rm -rf "$BUILD/Payload"
mkdir -p "$BUILD/Payload"
cp -R "$APP" "$BUILD/Payload/"

STAGED="$BUILD/Payload/$APP_NAME.app"
# Never ship a signed blob we cannot vouch for.
rm -rf "$STAGED/_CodeSignature" 2>/dev/null || true
# Test bundles and XCTest frameworks must NOT be in a shipped app.
rm -rf "$STAGED/PlugIns" 2>/dev/null || true
find "$STAGED/Frameworks" -maxdepth 1 \( -name "*XCTest*" -o -name "Testing.framework" -o -name "XCUnit*" -o -name "XCUIAutomation*" -o -name "XCTAutomationSupport*" -o -name "libXCTest*" \) -exec rm -rf {} + 2>/dev/null || true
if [ -d "$STAGED/Frameworks" ] && [ -z "$(ls -A "$STAGED/Frameworks" 2>/dev/null)" ]; then
  rmdir "$STAGED/Frameworks" 2>/dev/null || true
fi

# CFBundleExecutable must match the staged binary.
if command -v /usr/libexec/PlistBuddy >/dev/null 2>&1; then
  PLIST_EXEC=$(/usr/libexec/PlistBuddy -c "Print :CFBundleExecutable" "$STAGED/Info.plist" 2>/dev/null || echo "")
  if [ -n "$PLIST_EXEC" ] && [ "$PLIST_EXEC" != "$EXEC_NAME" ]; then
    echo "⚠️ CFBundleExecutable is '$PLIST_EXEC' but binary is '$EXEC_NAME' — renaming copy to match." >&2
    EXEC_NAME="$PLIST_EXEC"
    if [ -f "$STAGED/$EXEC_NAME" ]; then :; else mv "$STAGED/PackWise" "$STAGED/$EXEC_NAME"; fi
  fi
fi
[ -f "$STAGED/$EXEC_NAME" ] || { echo "❌ Staged app missing executable: $STAGED/$EXEC_NAME" >&2; exit 1; }
chmod +x "$STAGED/$EXEC_NAME"

echo "→ 5/6 Compressing Payload → $OUT_IPA ..."
if command -v ditto >/dev/null 2>&1; then
  (cd "$BUILD" && ditto -c -k --sequesterRsrc --keepParent Payload PackWise-unsigned.ipa)
  echo "   (ditto -c -k — Apple's canonical IPA tool, no __MACOSX)"
else
  (cd "$BUILD" && zip -r -X -y PackWise-unsigned.ipa Payload >/dev/null)
  echo "   (zip fallback)"
fi

echo "→ 6/6 Validating .ipa structure..."
ls -lh "$OUT_IPA"
command -v file >/dev/null 2>&1 && file "$OUT_IPA" || true
unzip -l "$OUT_IPA" | head -n 24
for required in "Payload/$APP_NAME.app/$EXEC_NAME" "Payload/$APP_NAME.app/Info.plist"; do
  if ! unzip -l "$OUT_IPA" | grep -q "$required"; then
    echo "❌ IPA missing $required — refusing to publish." >&2
    exit 1
  fi
done
if unzip -l "$OUT_IPA" | grep -qE "\.xctest/|Frameworks/XCTest" ; then
  echo "❌ IPA still contains test bundles — refusing to publish." >&2
  exit 1
fi

shasum -a 256 "$OUT_IPA" | tee "$BUILD/PackWise-unsigned.ipa.sha256"
echo ""
echo "✓ Unsigned IPA: ios/$OUT_IPA"
echo "  → This is the file to sideload. Verify:"
echo "      file $OUT_IPA                      # Zip archive data (correct)"
echo "      unzip -l $OUT_IPA | grep Payload   # Payload/PackWise.app/PackWise"
echo "      shasum -a 256 $OUT_IPA             # matches .sha256"
echo "  Sideload: AltStore / Sideloadly / TrollStore (re-sign on device)."
echo "  LiveContainer note: 'Failed to map …/PackWise: Bad file descriptor'"
echo "  means the app bundle had no executable — this script validates that."
