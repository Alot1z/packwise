# PackWise Wiki — Home

> **PackWise — Your trips, on device. Private by design.** Native iOS · SwiftUI · SwiftData · Vision · Offline.

![Hero — programmatic 3D](https://raw.githubusercontent.com/Alot1z/packwise/main/assets/packwise-hero.svg)

This Wiki, the [README](https://github.com/Alot1z/packwise#readme), and the [Live Freebuff Preview Site](https://github.com/Alot1z/packwise#live-docs) are one docs system — not copies. The README is the splash, the Preview is interactive, the Wiki is deep and versioned. They sync on every push to `main` (see [Build & Release](Build-and-Release)).

**Download (direct .ipa, no unwrap):** [Releases → Latest](https://github.com/Alot1z/packwise/releases/latest) · [dev — latest main](https://github.com/Alot1z/packwise/releases/tag/dev) · **Download (artifact — unwrap outer zip):** [Actions → iOS — PackWise](https://github.com/Alot1z/packwise/actions) → `PackWise-unsigned-ipa.zip` → `PackWise-unsigned.ipa` inside

## Start here

| Page | What's there |
|---|---|
| [Installation](Installation) | 3-step sideload — AltStore / Sideloadly / TrollStore — plus .zip vs .ipa |
| [Features](Features) | Everything inside the IPA — field-level |
| [Architecture](Architecture) | MVVM, services, navigation, frameworks |
| [Data Models](Data-Models) | All SwiftData models + fields |
| [Vision & Privacy](Vision-and-Privacy) | On-device Vision, confirm-before-add, no cloud |
| [Build & Release](Build-and-Release) | Reproducible IPA, archive+fallback, Gitea/act, dev + Releases |
| [Troubleshooting](Troubleshooting) | ".zip not .ipa", "No IPA artifact", "Untrusted Developer" |
| [Changelog](Changelog) | 1.0.0 + build notes |

## One-minute overview

- **Platform:** iOS 17+ · iPhone + iPad · Swift 5.9 · Xcode 16+ · XcodeGen
- **Storage:** SwiftData — all trips, items, outfits, reminders on device, offline, migrations, backup-safe
- **Vision:** `VNClassifyImageRequest` on device — import/scan photo → suggestions → **you confirm** → add to list
- **IPA:** `PackWise-unsigned.ipa` — built on `macos-15` (GitHub), `macos` (Gitea), or local `act` / `./ios/build.sh` — same artifact. Direct `.ipa` lives on **Releases** (`latest` + `dev`); artifact is the outer zip wrapper. Validate: `file *.ipa` → `Zip archive data`, `unzip -l *.ipa` → `Payload/PackWise.app/`

## Art is code

The hero above and architecture diagram are programmatic SVGs in [`assets/`](https://github.com/Alot1z/packwise/tree/main/assets) — hand-written, diffable.

## Honesty

No IPA claimed until a workflow has produced it. No TestFlight/App Store without Apple signing + App Store Connect. Unsigned IPAs are re-signed on install.
