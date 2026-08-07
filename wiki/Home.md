# PackWise Wiki — Home

> **PackWise — Your trips, on device. Private by design.** Native iOS · SwiftUI · SwiftData · Vision · Offline.

![Hero — programmatic 3D](https://raw.githubusercontent.com/Alot1z/packwise/main/assets/packwise-hero.svg)

This Wiki, the [README](https://github.com/Alot1z/packwise#readme), and the [Live Freebuff Preview Site](https://github.com/Alot1z/packwise#live-docs) are one docs system — not copies. The README is the splash, the Preview is interactive, the Wiki is deep and versioned. They sync on every push to `main` (see [Build & Release](Build-and-Release)).

**Download the app:** [Releases → Latest](https://github.com/Alot1z/packwise/releases/latest) · **Build logs:** [Actions](https://github.com/Alot1z/packwise/actions) · **Live docs:** this repo’s `src/` → `vite build`

## Start here

| Page | What’s there |
|---|---|
| [Installation](Installation) | 3-step sideload — AltStore / Sideloadly / TrollStore |
| [Features](Features) | Everything inside the IPA — field-level |
| [Architecture](Architecture) | MVVM, services, navigation, frameworks |
| [Data Models](Data-Models) | All SwiftData models + fields |
| [Vision & Privacy](Vision-and-Privacy) | On-device Vision, confirm-before-add, no cloud |
| [Build & Release](Build-and-Release) | Reproducible IPA, archive+fallback, Gitea/act, Releases, logs |
| [Troubleshooting](Troubleshooting) | “No IPA artifact” fix, “Untrusted Developer”, Vision misses |
| [Changelog](Changelog) | 1.0.0 + build notes |

## One-minute overview

- **Platform:** iOS 17+ · iPhone + iPad · Swift 5.9 · Xcode 16+ · XcodeGen
- **Storage:** SwiftData — all trips, items, outfits, reminders on device, offline, migrations, backup-safe
- **Vision:** `VNClassifyImageRequest` on device — import/scan photo → suggestions → **you confirm** → add to list
- **IPA:** `PackWise-unsigned.ipa` — built on `macos-15` (GitHub), `macos` (Gitea), or local `act` / `./ios/build.sh` — same artifact (zip of `Payload/PackWise.app`)

## Art is code

The hero above and the architecture diagram are not screenshots — they’re **programmatic SVGs** in [`assets/`](https://github.com/Alot1z/packwise/tree/main/assets) (`packwise-hero.svg`, `architecture.svg`, `og-image.svg`), hand-written and diffable. Edit the SVG, not an image export.

## Honesty

No IPA is claimed until a workflow has produced it. No TestFlight/App Store without Apple signing + App Store Connect. Unsigned IPAs are re-signed in AltStore/Sideloadly.

— *PackWise is an original implementation. No proprietary assets from the reference app are used.*
