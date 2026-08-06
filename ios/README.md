# PackWise — Native iOS · On-Device · Open Source

Premium, privacy-first packing assistant. SwiftUI + SwiftData + Vision (on device). Offline-first, no mandatory login, no paid APIs.

## Architecture

- **MVVM + Services:** `Services/VisionService` (Vision image classification, confirm-before-add), `Services/NotificationService` (UserNotifications).
- **Models (SwiftData):** `Trip`, `PackingItem`, `PersonalItem` (library, reusable), `Outfit`, `PackCategory`, `PackTemplate`/`TemplateItem`, `Reminder`, `UserPreference`. Single source of truth, migrations handled by SwiftData, backup-safe.
- **Navigation (no dead screens):** Launch → Onboarding → Dashboard → Trips → Trip Detail → Packing List (search/sort/filter) → Item Detail (photo/notes/favorite) → Photo Scanner (Vision) → Outfit Planner → Library → Templates (5 starters + custom) → Reminders → Settings.
- **Support:** Light/Dark, Dynamic Type, VoiceOver, iPhone + iPad, empty/loading/error states.

## Requirements

Xcode 16+, iOS 17+, Swift 5.9, XcodeGen (`brew install xcodegen`).

## Generate & run

```bash
cd ios
xcodegen generate
open PackWise.xcodeproj
# or simulator build:
xcodebuild build -project PackWise.xcodeproj -scheme PackWise -destination "generic/platform=iOS Simulator" -configuration Debug CODE_SIGNING_ALLOWED=NO
```

## Tests

```bash
cd ios
xcodegen generate
xcodebuild test -project PackWise.xcodeproj -scheme PackWise -destination "platform=iOS Simulator,name=iPhone 16,OS=latest" CODE_SIGNING_ALLOWED=NO
# Suites: PackWiseTests (unit + model + persistence) + PackWiseUITests (launch + tabs)
```

## Unsigned IPA (sideloading)

No Apple Developer account needed.

**CI (free, no Mac required):** Push to `main` → GitHub Actions `macos-15` runs tests, archives with `CODE_SIGNING_ALLOWED=NO`, zips `Payload/PackWise.app` → `PackWise-unsigned.ipa` artifact (`PackWise-unsigned-ipa`, 14 days). Manual: Actions → *iOS — PackWise* → Run workflow.

**Local:**

```bash
./ios/build.sh
# → ios/build/PackWise-unsigned.ipa
```

Sideload via **AltStore / Sideloadly / TrollStore** (re-sign on device/PC). Unsigned IPA cannot be installed directly.

## Web companion

Static Vite build (`vite build` → `dist/`) deployable to Vercel/Netlify/CF Pages/GitHub Pages. The iOS core has no cloud dependency.

## Honesty contract

- Do not claim an IPA is downloadable until a workflow has succeeded.
- Do not claim TestFlight/App Store until a signed build has been uploaded and processed by Apple in App Store Connect.

## License

MIT — see `LICENSE`.
