# PackWise — iOS (SwiftUI, on-device, offline-first)

Native iOS app. All core data (trips, packing lists, items, outfits, templates, photos/notes, progress) is stored locally via **SwiftData**. No account, server, or paid API required. Works fully offline.

## Requirements

- Xcode 16+, iOS 17+, Swift 5.9+
- [XcodeGen](https://github.com/yonaskolb/XcodeGen): `brew install xcodegen`

## Generate & build locally

```bash
cd ios
xcodegen generate
open PackWise.xcodeproj

# Build (simulator, no signing)
xcodebuild build -project PackWise.xcodeproj -scheme PackWise -destination "generic/platform=iOS Simulator" -configuration Release CODE_SIGNING_ALLOWED=NO
```

## Unsigned IPA (sideloading) — no Apple Developer account

The GitHub Actions workflow `.github/workflows/ios.yml` builds on `macos-15` and produces an **unsigned IPA**.

- **Trigger:** push to `main` touching `ios/**`, or manual **Run workflow**.
- **Artifact:** `PackWise-unsigned-ipa` → `PackWise-unsigned.ipa` (a zipped `Payload/PackWise.app`).
- **Sideload:** install with [AltStore](https://altstore.io/), [Sideloadly](https://sideloadly.io/), or TrollStore (requires re-signing on device/PC). No App Store distribution.

> The unsigned IPA is **not** App Store signed and cannot be installed directly without a sideloading tool.

### Code path (no Mac required — CI does it)

```
xcodegen generate
xcodebuild archive -project PackWise.xcodeproj -scheme PackWise -destination "generic/platform=iOS" -archivePath build/PackWise.xcarchive CODE_SIGNING_ALLOWED=NO
mkdir -p build/Payload && cp -R build/PackWise.xcarchive/Products/Applications/PackWise.app build/Payload
(cd build && zip -r PackWise-unsigned.ipa Payload)
```

## TestFlight / App Store (requires Apple Developer Program)

This repo does **not** claim TestFlight availability. To publish:

1. In Xcode, set **Signing & Capabilities** → Team, bundle `com.packwise.app`, automatic signing.
2. Create App record in App Store Connect.
3. Archive: `Product → Archive`, then **Distribute → TestFlight**, or via `fastlane`/`xcodebuild -exportArchive` with a signed export options plist.
4. Upload is processed by Apple before TestFlight becomes available — the app is **not** on TestFlight until Apple finishes processing and you submit for review.

## Free hosting alternative

For the **web** companion: deploy on any static host (Vercel, Netlify, Cloudflare Pages, or GitHub Pages) via `vite build` output in `dist/`. No proprietary backend required for the iOS app’s core.

## Honesty contract

- Do not claim the IPA is downloadable until the workflow has succeeded and an artifact/Release exists.
- Do not claim TestFlight availability until a signed build has been uploaded and processed by App Store Connect.
