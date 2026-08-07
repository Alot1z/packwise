# PackWise iOS — the app is the product

Native, private, offline. SwiftUI + SwiftData + Vision — everything on device.

> **Get the IPA →** [Releases · Latest](https://github.com/Alot1z/packwise/releases/latest) · **[dev · latest main](https://github.com/Alot1z/packwise/releases/tag/dev)** (direct `.ipa`, no unwrap) · or **Actions → artifact** (unwrap the outer zip to get the `.ipa`)
> This doc is for building it yourself.

## Quick start

```bash
brew install xcodegen
cd ios
xcodegen generate
open PackWise.xcodeproj
```

Simulator build (no signing):

```bash
xcodebuild build -project PackWise.xcodeproj -scheme PackWise \
  -destination "platform=iOS Simulator,name=iPhone 16,OS=latest" CODE_SIGNING_ALLOWED=NO
```

## What's inside

**Models (SwiftData):** `Trip` · `PackingItem` · `PersonalItem` · `Outfit` · `PackCategory` · `PackTemplate` · `Reminder` · `UserPreference` — local, offline, backup-safe.

**Services:** `VisionService` (on-device `VNClassifyImageRequest`, confirm-before-add) · `NotificationService` (local `UserNotifications`) · `RecommendationService` (rule-based, no cloud).

**Navigation (no dead screens):** Launch → Onboarding → **Dashboard** → **Trips** → **Trip Detail** → **Item Detail** → **Photo Scanner** → **Outfit Planner** → **Library** → **Search** → **Templates** → **Reminders** → **Settings**. Light/Dark, Dynamic Type, VoiceOver, iPhone + iPad.

## Tests

```bash
cd ios && xcodegen generate
xcodebuild test -project PackWise.xcodeproj -scheme PackWise \
  -destination "platform=iOS Simulator,name=iPhone 16,OS=latest" CODE_SIGNING_ALLOWED=NO
```

Targets: `PackWise` · `PackWiseTests` · `PackWiseUITests`.

## Unsigned IPA — reproducible, three equal hosts

All three produce the identical `PackWise-unsigned.ipa` (zip of `Payload/PackWise.app`) — sideload via AltStore / Sideloadly / TrollStore.

### 1 — GitHub Actions (no Mac needed on your side)

Push to `main` → **artifact** (outer zip, unwrap to get the `.ipa`) **+ `dev` prerelease** (direct `.ipa` at `releases/tag/dev`). Tag `v*` → versioned Release (direct `.ipa`).

```bash
git tag v1.0.0 && git push origin v1.0.0
gh release download dev -R Alot1z/packwise -p "PackWise-unsigned.ipa"  # direct, no unwrap
```

Runner: `macos-15` + Xcode 16. Keep: 14 days. Every push or *Actions → iOS — PackWise → Run workflow* builds.

### 2 — Gitea Actions (self-hosted, FOSS)

Same YAML at `.gitea/workflows/ios.yml` (`runs-on: macos`). Enable `[actions]` in `app.ini`, register a **macOS runner** labeled `macos`. See https://docs.gitea.io/en-us/usage/actions/comparison/

```bash
git remote add gitea https://YOUR_GITEA/YOU/packwise.git && git push gitea main
```

### 3 — act locally (nektos/act, fully offline after clone)

Requires a **Mac + Xcode** (Linux cannot run `xcodebuild`):

```bash
brew install act
act -W .github/workflows/ios.yml -P macos-15=-self-hosted
./ios/build.sh   # → ios/build/PackWise-unsigned.ipa + .sha256
```

`.actrc` maps `macos-15`/`macos` → `-self-hosted`.

### Why you got a .zip (artifact) vs a direct .ipa (Releases)

`upload-artifact` **wraps** uploads in an outer container zip for "Download artifact" — that's GitHub's design, not the PackWise build. Inside the artifact zip is `PackWise-unsigned.ipa` (the real `Payload/*.app` zip). On **Releases** you download the raw `.ipa` directly — that's why we now publish `dev` on every main push.

### How the IPA is built (validated, device-first)

`xcodebuild archive` with `CODE_SIGNING_ALLOWED=NO` on Xcode 16 can exit 0 while emitting an app shell **without the main executable** — which sideloaders report as `Failed to map …/PackWise: Bad file descriptor` (the file is not there). So the pipeline no longer uses `archive`:

1. **Build** — `xcodebuild build -sdk iphoneos -destination "generic/platform=iOS" -derivedDataPath build/DerivedData` → `Release-iphoneos/PackWise.app` (a real **device arm64** binary, never a simulator build).
2. **Validate the executable** — `Payload/PackWise.app/PackWise` must exist, be non-empty, be arm64 (`file`), carry the iOS device platform (`otool -l` → `LC_BUILD_VERSION platform 2`, not 7 = simulator); any `x86_64` slice is stripped via `lipo -thin arm64`.
3. **Strip test injection** — `PlugIns/*.xctest`, `_CodeSignature`, and XCTest frameworks are removed from the staged bundle.
4. **Package** — `ditto -c -k --sequesterRsrc --keepParent Payload PackWise-unsigned.ipa` (zip fallback on non-macOS).
5. **Publish gate** — the `.ipa` MUST contain `Payload/PackWise.app/PackWise` + `Info.plist` and NO `.xctest` entries, or the workflow **fails** — nothing broken is ever released.

```bash
file ios/build/PackWise-unsigned.ipa
unzip -l ios/build/PackWise-unsigned.ipa | grep Payload
shasum -a 256 ios/build/PackWise-unsigned.ipa
```

## Troubleshooting

- **Download was a .zip?** → Use the direct `.ipa` on Releases (`latest` or `dev`), or unzip the artifact zip.
- **Install fails / Untrusted Developer** → Re-sign via AltStore/Sideloadly, or TrollStore where supported.
- **Vision finds nothing** → Clearer, well-lit photo; on-device Vision is conservative.
- **Build says "no IPA"** → Open the *Build unsigned IPA* step logs — diagnostics + `file` + `unzip -l` always print.
- **Sideloader says "Failed to map …/PackWise: Bad file descriptor"** → you have a pre-fix IPA (it had no executable). Use the latest `dev` build or run `./ios/build.sh` — the executable is now validated before publishing.

## Honesty

No IPA advertised until a workflow has produced it. No TestFlight/App Store without Apple signing + App Store Connect.
