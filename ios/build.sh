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

echo "→ Archiving (generic iOS, unsigned)..."
xcodebuild archive \
  -project PackWise.xcodeproj \
  -scheme PackWise \
  -configuration Release \
  -destination "generic/platform=iOS" \
  -archivePath build/PackWise.xcarchive \
  CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO CODE_SIGN_IDENTITY="" | tail -n 40

if [ -d build/PackWise.xcarchive/Products/Applications/PackWise.app ]; then
  rm -rf build/Payload build/PackWise-unsigned.ipa
  mkdir -p build/Payload
  cp -R build/PackWise.xcarchive/Products/Applications/PackWise.app build/Payload/
  (cd build && zip -r PackWise-unsigned.ipa Payload >/dev/null)
  echo "✓ Unsigned IPA: ios/build/PackWise-unsigned.ipa"
  echo "  Sideload with AltStore / Sideloadly / TrollStore (re-sign on device)."
else
  echo "Archive produced no .app — check xcodebuild output." >&2
  exit 1
fi
