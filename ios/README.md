# PackWise — Native iOS · On-Device · Open Source

Premium, privacy-first packing assistant. SwiftUI + SwiftData + Vision (on device). Offline-first, no mandatory login, no paid APIs.

## Architecture

- **MVVM + Services:** `Services/VisionService` (Vision, confirm-before-add), `Services/NotificationService` (UserNotifications), `Services/RecommendationService` (local rules).
- **Models (SwiftData):** `Trip`, `PackingItem`, `PersonalItem`, `Outfit`, `PackCategory`, `PackTemplate`, `Reminder`, `UserPreference`. Migrations handled by SwiftData, backup-safe.
- **Navigation:** Launch → Onboarding → Dashboard → Trips → Trip Detail → Packing List (search/sort/filter) → Item Detail (photo/notes) → Photo Scanner (Vision) → Outfit Planner → Library → Global Search → Templates (5 starters + custom) → Reminders → Settings.
- **Support:** Light/Dark, Dynamic Type, VoiceOver, iPhone + iPad, empty/loading/error states.

## Requirements

Xcode 16+, iOS 17+, Swift 5.9, XcodeGen (`brew install xcodegen`).

## Generate & run

```bash
cd ios
xcodegen generate
open PackWise.xcodeproj
# or:
xcodebuild build -project PackWise.xcodeproj -scheme PackWise -destination "generic/platform=iOS Simulator" CODE_SIGNING_ALLOWED=NO
```

## Tests

```bash
cd ios
xcodegen generate
xcodebuild test -project PackWise.xcodeproj -scheme PackWise -destination "platform=iOS Simulator,name=iPhone 16,OS=latest" CODE_SIGNING_ALLOWED=NO
```

## Unsigned IPA — fully open, fully reproducible

The same `ios/` source builds identically on **any** of these (pick what you prefer — no lock-in):

### 1) GitHub Actions (free, no Mac needed on your side)

Push to `main` → workflow `.github/workflows/ios.yml` runs on `macos-15` (Xcode 16), runs tests, archives with `CODE_SIGNING_ALLOWED=NO`, zips `Payload/PackWise.app` → artifact `PackWise-unsigned-ipa` (14 days). Manual: Actions → *iOS — PackWise* → Run workflow.

### 2) Gitea Actions (self-hosted, FOSS)

Mirroring is trivial — the YAML is the same.

- Host Gitea (https://about.gitea.com/) and enable **Actions** (`[actions] ENABLED=true` in `app.ini`).
- Add a **macOS runner** (must be a Mac with Xcode): register a runner labeled `macos` against your Gitea instance. See https://docs.gitea.io/en-us/usage/actions/comparison/ and https://docs.gitea.io/en-us/usage/actions/act-runner/.
- Mirror or push this repo to Gitea. Workflow at `.gitea/workflows/ios.yml` (identical to GitHub's, `runs-on: macos`) will build the same unsigned IPA and upload artifact `PackWise-unsigned-ipa`.

> GitHub stabilizes / Gitea fluctuates? Just `git push` to the other remote — no YAML rewrite. The two workflows are mirrors by design.

### 3) Self-hosted `act` (nektos/act — run Actions locally, 100% offline if you want)

`act` lets you execute the GitHub Actions YAML **on your own machine**, including a Mac you control. Fully FOSS, no cloud required after clone. Requires macOS + Xcode to actually compile iOS (hard Apple requirement — Linux cannot run `xcodebuild`).

```bash
# On your Mac:
brew install act
# Dry-run the same workflow locally, on the host (no Docker, so Xcode is available):
act -W .github/workflows/ios.yml -P macos-15=-self-hosted -P macos=-self-hosted
# → ios/build/PackWise-unsigned.ipa

# Or skip act entirely and just:
./ios/build.sh
```

Config for `act` is in `.actrc` at repo root. Linux `act` can lint workflows but cannot build IPAs — again, Apple toolchain only on macOS.

**All three produce the same `PackWise-unsigned.ipa`:** a zip of `Payload/PackWise.app` suitable for **AltStore / Sideloadly / TrollStore** (re-sign on device/PC). Unsigned IPAs are not App Store signed.

## Web companion

Static Vite build (`vite build` → `dist/`) — docs only. The IPA is the product. Deployable to any static host.

## Honesty contract

- Do not claim an IPA is downloadable until a workflow (any host) has succeeded.
- Do not claim TestFlight/App Store until a signed build has been uploaded and processed by Apple.
