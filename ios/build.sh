#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────────────────────
# PackWise — unsigned IPA build (reproducible, sideload-ready, self-healing)
#
# Produces:  ios/build/PackWise-unsigned.ipa  (+ .sha256)
#
# Why multiple strategies? Xcode 16+ with CODE_SIGNING_ALLOWED=NO can exit 0
# while emitting an app shell WITHOUT the main executable (or with test bundles
# injected) — exactly the sideload failure:
#     Failed to map …/PackWise: Bad file descriptor   (the file is not there)
# The strategies (device build → archive → legacy → minimal) handle Xcode
# version-specific quirks like missing device platforms, empty shells, and
# test-bundle injection. Every candidate is validated: the executable must
# exist, be non-empty, be arm64 Mach-O, and carry the iOS device platform
# (LC_BUILD_VERSION 2, never 7 = simulator). Test bundles are stripped, then
# the FINAL .ipa must pass a strict publish gate or the script fails loudly —
# nothing broken is ever released.
#
# Source note: the app uses ONLY `.searchable(text:)` for search — iOS provides
# a built-in clear (X) button automatically. An earlier version attempted to
# add a custom clear button via a nonexistent `.searchActions` API (which does
# not exist in SwiftUI). That file (SearchClearActionsModifier.swift) has been
# removed — the native `.searchable()` clear button is sufficient.
#
# Full diagnostics go to build/diagnostics.txt (uploaded by CI even on failure,
# so any future failure is publicly readable).
#
# CI notes: GitHub Actions *logs* and *artifacts* require sign-in (403/401),
# but check-run ANNOTATIONS are public. So on failure this script also emits
# `::error::` workflow-command lines with the real error text — they surface
# in the public annotations API without any credentials.
# ─────────────────────────────────────────────────────────────────────────────
set -euo pipefail
cd "$(dirname "$0")"

BUILD=build
APP_NAME=PackWise
EXEC_NAME=PackWise
OUT_IPA="$BUILD/PackWise-unsigned.ipa"
BUILD_LOG="$BUILD/build.log"
DIAG="$BUILD/diagnostics.txt"

# 2026-08-08 (session 6): macOS-15 runner images trim the iOS DEVICE platform
# (actions/runner-images #12758/#12862/#13570). `xcodebuild -destination
# "generic/platform=iOS"` then fails in <1s with:
#   Unable to find a destination ... error:iOS 18.0 is not installed
# The official fix is `xcodebuild -downloadPlatform iOS` (no-op if present).
# The workflow runs that step before us; this guard also self-heals when
# build.sh is invoked standalone (e.g. local macOS dev).
ensure_device_platform() {
  if ! xcodebuild -showsdks 2>/dev/null | grep -qi 'iphoneos'; then
    echo "→ iOS device SDK not visible — running xcodebuild -downloadPlatform iOS"
    if ! xcodebuild -downloadPlatform iOS 2>&1 | tail -n 5; then
      echo "→ retrying with sudo (platform dir is root-owned on runners)"
      sudo xcodebuild -downloadPlatform iOS 2>&1 | tail -n 5 || true
    fi
  fi
}

# Unsigned device builds: disable every signing hook so Xcode never demands a
# development team or certificate for an artifact we ship unsigned (sideloaders
# re-sign locally).
#
# 2026-08-08 (session 5): the string form word-split into LITERAL quote chars
# (`CODE_SIGN_IDENTITY=""`) and an explicit `DEVELOPMENT_TEAM=` — even empty —
# made Xcode 15/16 try to resolve a team, failing instantly with "requires a
# development team". This session (5b): dropped `CODE_SIGN_STYLE=Manual` too —
# the CI *tests* step (which passes) uses exactly
# `CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO CODE_SIGN_IDENTITY=""` and
# no style override; forcing Manual style on Xcode 16 can itself trigger team
# resolution even with signing disabled. Matching the proven-passing flags.
NO_SIGN=(CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO CODE_SIGN_IDENTITY=)

mkdir -p "$BUILD"
: > "$DIAG"

say()  { printf '%s\n' "$*"; }
note() { printf '%s\n' "$*" | tee -a "$DIAG"; }

diag_tail() { tail -n 140 "$BUILD_LOG" >> "$DIAG" || true; }

# Ensure the iOS device platform is present (see header) before any strategy.
ensure_device_platform

# Emit the real error lines as GitHub Actions annotations (public, no auth).
emit_annotations() {
  if [ -f "$BUILD_LOG" ]; then
    grep -nE "error:|fatal error|FAILED|requires a development team|Signing|CodeSign|Unable to find|does not exist|no such module|error: " "$BUILD_LOG" \
      | tail -n 8 | while IFS= read -r line; do
        printf '::error file=ios/build.sh,line=0::%s\n' "$(echo "$line" | cut -c1-300)" || true
      done || true
  fi
}

die() {
  note ""
  note "════════ DIAGNOSTICS (also written to $DIAG) ════════"
  if [ -f "$BUILD_LOG" ]; then
    note "--- last 140 lines of build/build.log ---"
    diag_tail
  fi
  if [ -n "${LAST_APP:-}" ] && [ -d "$LAST_APP" ]; then
    note "--- contents of last produced app bundle: $LAST_APP ---"
    ls -la "$LAST_APP" >> "$DIAG" 2>&1 || true
  fi
  note "--- DerivedData products (depth 6) ---"
  find "$BUILD" -maxdepth 6 -type d 2>/dev/null | head -n 60 >> "$DIAG" || true
  note "══════════════════════════════════════════════════════"
  emit_annotations
  echo "❌ $*" >&2
  exit 1
}

if ! command -v xcodegen >/dev/null 2>&1; then
  die "xcodegen not found — install with: brew install xcodegen"
fi

note "→ 0/7 Generating Xcode project"
xcodegen generate >/dev/null

rm -rf "$BUILD/DerivedData" "$BUILD/DerivedData-C" "$BUILD/DerivedData-D" "$BUILD/Payload" "$OUT_IPA" "$BUILD/PackWise.xcarchive"
: > "$BUILD_LOG"

# ── strategy helpers ────────────────────────────────────────────────────────
# run_build "<label>" <xcodebuild args...>  → appends log, honours failure
run_build() {
  local label="$1"; shift
  note ""
  note "→ trying strategy: $label"
  # shellcheck disable=SC2086
  xcodebuild "$@" 2>&1 | tee -a "$BUILD_LOG" | tail -n 25
  local rc=${PIPESTATUS[0]}
  if [ "$rc" != "0" ]; then
    # Make the next failure readable at a glance: extract the real error lines.
    echo "   ── error lines (last 12) ──" >> "$DIAG"
    grep -nE "error:|fatal error|FAILED|does not exist|requires a development team|Signing|CodeSign" "$BUILD_LOG" \
      | tail -n 12 >> "$DIAG" 2>/dev/null || true
    emit_annotations
  fi
  return "$rc"
}

# validate_app <app dir> → echo path if the executable is a real device binary
validate_app() {
  local app="$1"
  [ -d "$app" ] || return 1
  [ -f "$app/Info.plist" ] || return 1
  local exec="$app/$EXEC_NAME"
  if [ ! -f "$exec" ] || [ ! -s "$exec" ]; then
    note "   ⚠ $app has no non-empty main executable — strategy unusable"
    note "   ── bundle contents ──"
    ls -la "$app" >> "$DIAG" 2>&1 || true
    find "$app" -maxdepth 2 -type f 2>/dev/null | head -n 30 >> "$DIAG" || true
    note "   ── end bundle contents ──"
    return 1
  fi
  chmod +x "$exec" 2>/dev/null || true
  if command -v file >/dev/null 2>&1; then
    local kind
    kind=$(file "$exec" || true)
    note "   file: $kind"
    case "$kind" in
      *arm64*) : ;;
      *) note "   ⚠ not arm64 — strategy unusable"; return 1 ;;
    esac
  fi
  if command -v otool >/dev/null 2>&1; then
    local plat
    plat=$(otool -l "$exec" 2>/dev/null | grep -A5 "LC_BUILD_VERSION" | grep -m1 "platform" | awk '{print $2}' || true)
    note "   LC_BUILD_VERSION platform=$plat (2=iOS device, 7=simulator)"
    if [ "$plat" = "7" ]; then note "   ⚠ simulator binary — cannot sideload"; return 1; fi
  fi
  if command -v lipo >/dev/null 2>&1 && lipo -info "$exec" 2>/dev/null | grep -q "x86_64"; then
    note "   → stripping non-arm64 slices (lipo -thin arm64)"
    lipo -thin arm64 "$exec" -output "$exec.tmp" && mv "$exec.tmp" "$exec"
  fi
  echo "$app"
}

APP=""
BUILT_BY=""

# A — modern device build (fresh DerivedData)
if [ -z "$APP" ]; then
  if run_build "A · xcodebuild build -sdk iphoneos (device arm64)" \
      build -project PackWise.xcodeproj -scheme PackWise \
      -configuration Release -sdk iphoneos \
      -destination "generic/platform=iOS" \
      -derivedDataPath "$BUILD/DerivedData" \
      ONLY_ACTIVE_ARCH=NO ARCHS="arm64" ENABLE_TESTABILITY=NO \
      "${NO_SIGN[@]}" -skipPackagePluginValidation -skipMacroValidation; then
    APP=$(validate_app "$BUILD/DerivedData/Build/Products/Release-iphoneos/$APP_NAME.app" || true)
    [ -n "$APP" ] && BUILT_BY="A"
  else
    note "   ⚠ strategy A exited non-zero — continuing"
  fi
fi

# B — classic archive
if [ -z "$APP" ]; then
  if run_build "B · xcodebuild archive (classic)" \
      archive -project PackWise.xcodeproj -scheme PackWise \
      -configuration Release -sdk iphoneos \
      -destination "generic/platform=iOS" \
      -archivePath "$BUILD/PackWise.xcarchive" \
      ONLY_ACTIVE_ARCH=NO ARCHS="arm64" ENABLE_TESTABILITY=NO \
      "${NO_SIGN[@]}" -skipPackagePluginValidation -skipMacroValidation; then
    APP=$(validate_app "$BUILD/PackWise.xcarchive/Products/Applications/$APP_NAME.app" || true)
    [ -n "$APP" ] && BUILT_BY="B"
  else
    note "   ⚠ strategy B exited non-zero — continuing"
  fi
fi

# C — legacy build (no -destination)
if [ -z "$APP" ]; then
  if run_build "C · xcodebuild build (legacy, no destination)" \
      build -project PackWise.xcodeproj -scheme PackWise \
      -configuration Release -sdk iphoneos \
      -derivedDataPath "$BUILD/DerivedData-C" \
      ONLY_ACTIVE_ARCH=NO ARCHS="arm64" ENABLE_TESTABILITY=NO \
      "${NO_SIGN[@]}" -skipPackagePluginValidation -skipMacroValidation; then
    APP=$(validate_app "$BUILD/DerivedData-C/Build/Products/Release-iphoneos/$APP_NAME.app" || true)
    [ -n "$APP" ] && BUILT_BY="C"
  else
    note "   ⚠ strategy C exited non-zero — continuing"
  fi
fi

# D — minimal flags (mirrors the CI tests step that passes on the same runner)
if [ -z "$APP" ]; then
  if run_build "D · xcodebuild build (minimal — mirrors passing tests step)" \
      build -project PackWise.xcodeproj -scheme PackWise \
      -configuration Release -sdk iphoneos \
      -derivedDataPath "$BUILD/DerivedData-D" \
      "${NO_SIGN[@]}"; then
    APP=$(validate_app "$BUILD/DerivedData-D/Build/Products/Release-iphoneos/$APP_NAME.app" || true)
    [ -n "$APP" ] && BUILT_BY="D"
  else
    note "   ⚠ strategy D exited non-zero — continuing"
  fi
fi

if [ -z "$APP" ]; then
  LAST_APP="$BUILD/DerivedData/Build/Products/Release-iphoneos/$APP_NAME.app"
  die "no usable PackWise.app produced (all 4 strategies). See diagnostics above."
fi
note "✓ app bundle produced by strategy $BUILT_BY: $APP"

EXEC="$APP/$EXEC_NAME"

# ── stage Payload/PackWise.app ──────────────────────────────────────────────
note "→ 4/7 Staging Payload (stripping test injection)"
rm -rf "$BUILD/Payload"
mkdir -p "$BUILD/Payload"
cp -R "$APP" "$BUILD/Payload/"

STAGED="$BUILD/Payload/$APP_NAME.app"
chmod -R u+w "$STAGED" 2>/dev/null || true
# Never ship a signed blob we cannot vouch for.
rm -rf "$STAGED/_CodeSignature" "$STAGED/PlugIns" "$STAGED/SC_Info" 2>/dev/null || true
# Any XCTest/XC*/Testing artifacts anywhere in the bundle.
find "$STAGED" \( -name "*.xctest" -o -name "*XCTest*" -o -name "*XCUnit*" \
  -o -name "*XCUIAutomation*" -o -name "*XCTAutomationSupport*" \
  -o -name "*XCTestSupport*" -o -name "Testing.framework" -o -name "libXCTest*" \
  -o -name "libTesting*" \) -exec rm -rf {} + 2>/dev/null || true
if [ -d "$STAGED/Frameworks" ] && [ -z "$(ls -A "$STAGED/Frameworks" 2>/dev/null)" ]; then
  rmdir "$STAGED/Frameworks" 2>/dev/null || true
fi

# CFBundleExecutable must match the staged binary.
if command -v /usr/libexec/PlistBuddy >/dev/null 2>&1; then
  PLIST_EXEC=$(/usr/libexec/PlistBuddy -c "Print :CFBundleExecutable" "$STAGED/Info.plist" 2>/dev/null || echo "")
  if [ -n "$PLIST_EXEC" ] && [ "$PLIST_EXEC" != "$EXEC_NAME" ]; then
    note "→ CFBundleExecutable is '$PLIST_EXEC' — renaming staged copy to match"
    EXEC_NAME="$PLIST_EXEC"
    [ -f "$STAGED/$EXEC_NAME" ] || mv "$STAGED/PackWise" "$STAGED/$EXEC_NAME"
  fi
fi
[ -f "$STAGED/$EXEC_NAME" ] || die "staged app missing executable: $STAGED/$EXEC_NAME"
chmod +x "$STAGED/$EXEC_NAME"

# ── compress → .ipa ─────────────────────────────────────────────────────────
note "→ 5/7 Compressing Payload → $OUT_IPA"
if command -v ditto >/dev/null 2>&1; then
  (cd "$BUILD" && ditto -c -k --sequesterRsrc --keepParent Payload PackWise-unsigned.ipa)
  note "   (ditto -c -k — Apple's canonical IPA tool, no __MACOSX)"
else
  (cd "$BUILD" && zip -r -X -y PackWise-unsigned.ipa Payload >/dev/null)
  note "   (zip fallback)"
fi

# ── strict publish gate ─────────────────────────────────────────────────────
note "→ 6/7 Validating .ipa structure (publish gate)"
ls -lh "$OUT_IPA" || die "no .ipa produced"
command -v file >/dev/null 2>&1 && file "$OUT_IPA" || true
unzip -l "$OUT_IPA" | head -n 30 || true
unzip -tq "$OUT_IPA" >/dev/null 2>&1 || die "zip integrity check failed"

for required in "Payload/$APP_NAME.app/$EXEC_NAME" "Payload/$APP_NAME.app/Info.plist"; do
  if ! unzip -l "$OUT_IPA" | grep -q "$required"; then
    die "IPA missing $required — refusing to publish"
  fi
done
if unzip -l "$OUT_IPA" | grep -qE "\.xctest|XCTest|XCUnit|XCUIAutomation|XCTAutomationSupport|XCTestSupport|Testing\.framework|libXCTest|libTesting|_CodeSignature"; then
  die "IPA still contains test/signing artifacts — refusing to publish"
fi

shasum -a 256 "$OUT_IPA" | tee "$BUILD/PackWise-unsigned.ipa.sha256"

note "→ 7/7 Done"
note ""
note "✓ Unsigned IPA: ios/$OUT_IPA   (built via strategy $BUILT_BY)"
note "  Verify:"
note "    ../scripts/verify-ipa.sh $OUT_IPA    # one command: sideload-ready or exactly why not"
note "    file $OUT_IPA                        # Zip archive data (correct)"
note "    unzip -l $OUT_IPA | grep Payload     # Payload/PackWise.app/PackWise"
note "    shasum -a 256 $OUT_IPA               # matches .sha256"
note "  Sideload: AltStore / Sideloadly / TrollStore (re-sign on device)."
note "  LiveContainer note: 'Failed to map …/PackWise: Bad file descriptor'"
note "  means the app bundle had no executable — this script validates that."
