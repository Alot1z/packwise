#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"

if ! command -v xcodegen >/dev/null 2>&1; then
  echo "xcodegen not found. Install: brew install xcodegen" >&2
  exit 1
fi

echo "→ Generating Xcode project..."
xcodegen generate

echo "→ Building (simulator, no signing)..."
xcodebuild build \
  -project PackWise.xcodeproj \
  -scheme PackWise \
  -destination "generic/platform=iOS Simulator" \
  -configuration Release \
  CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO CODE_SIGN_IDENTITY="" | tail -n 40

echo "→ Archiving (generic iOS, unsigned) — with fallback to DerivedData build..."
rm -rf build/Payload build/PackWise-unsigned.ipa build/DerivedData

set +e
xcodebuild archive \
  -project PackWise.xcodeproj \
  -scheme PackWise \
  -configuration Release \
  -destination "generic/platform=iOS" \
  -archivePath build/PackWise.xcarchive \
  CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO CODE_SIGN_IDENTITY="" \
  -skipPackagePluginValidation -skipMacroValidation 2>&1 | tee build/archive.log | tail -n 80
set -e

APP=""
if [ -f build/PackWise.xcarchive/Products/Applications/PackWise.app/Info.plist ]; then
  APP="build/PackWise.xcarchive/Products/Applications/PackWise.app"
else
  echo "⚠️ Archive did not emit .app — building for generic iOS device instead..."
  xcodebuild build \
    -project PackWise.xcodeproj \
    -scheme PackWise \
    -configuration Release \
    -destination "generic/platform=iOS" \
    -derivedDataPath build/DerivedData \
    CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO CODE_SIGN_IDENTITY="" 2>&1 | tail -n 80
  APP=$(find build/DerivedData -name "PackWise.app" -type d | head -n1 || true)
fi

if [ -z "$APP" ] || [ ! -d "$APP" ]; then
  echo "❌ No PackWise.app found — check logs above." >&2
  find build -type d 2>&1 | head -n 60 || true
  ls -R build 2>&1 | head -n 100 || true
  exit 1
fi

rm -rf build/Payload build/PackWise-unsigned.ipa
mkdir -p build/Payload
cp -R "$APP" build/Payload/
find build/Payload -name "_CodeSignature" -type d -exec rm -rf {} + 2>/dev/null || true
(cd build && zip -r -y PackWise-unsigned.ipa Payload >/dev/null)
echo "--- IPA validation ---"
ls -lh build/PackWise-unsigned.ipa
file build/PackWise-unsigned.ipa || true
unzip -l build/PackWise-unsigned.ipa | head -n 24
if ! unzip -l build/PackWise-unsigned.ipa | grep -q "Payload/PackWise.app/"; then
  echo "❌ IPA missing Payload/PackWise.app/ — not installable" >&2
  exit 1
fi
shasum -a 256 build/PackWise-unsigned.ipa > build/PackWise-unsigned.ipa.sha256
echo "✓ Unsigned IPA: ios/build/PackWise-unsigned.ipa"
cat build/PackWise-unsigned.ipa.sha256
echo "  → This is the file to sideload. No extra zipping needed."
echo "  Sideload: AltStore / Sideloadly / TrollStore (re-sign on device)."
