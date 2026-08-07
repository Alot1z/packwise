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

**Accessibility:** every interactive control carries an explicit VoiceOver label (item toggles say "Mark {name} as packed/unpacked", template buttons name their template, Vision suggestions expose selection state); decorative images are hidden from VoiceOver; packing `ProgressView`s are labeled; trip rows combine into a single announcement. Guarded by the `testItemToggleHasVoiceOverLabel` UI test.

**Dynamic Type:** every text element uses a scalable text style (`.caption` … `.title3`) — no fixed-size fonts remain after the 1.0.5 audit. The onboarding hero icon scales via `@ScaledMetric(relativeTo: .largeTitle)`. Test in *Settings → Accessibility → Display & Text Size* at sizes up to accessibility maximums; rows and sheets reflow and wrap.

**Reduced Motion & Contrast (1.0.6):** Onboarding's `withAnimation` gates on `accessibilityReduceMotion`; all essentials warnings and favorite/essential stars use high-contrast browns/ambers (≥4.5:1) paired with icons so state is never color-only. Test in *Settings → Accessibility → Motion → Reduce Motion* and *Display & Text Size → Increase Contrast / Smart Invert*.

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

### How the IPA is built (validated, device-first, self-healing)

Xcode 16 with `CODE_SIGNING_ALLOWED=NO` can exit 0 while emitting an app shell **without the main executable** (or with test bundles injected) — sideloaders report that as `Failed to map …/PackWise: Bad file descriptor` (the file is not there). We confirmed it by inspecting the old published `dev` IPA. `build.sh` therefore tries **three strategies in order** and validates every candidate:

1. **A · Build** — `xcodebuild build -sdk iphoneos -destination "generic/platform=iOS" -derivedDataPath build/DerivedData` → `Release-iphoneos/PackWise.app` (a real **device arm64** binary, never a simulator build).
2. **B · Archive** — `xcodebuild archive -archivePath build/PackWise.xcarchive` → `Products/Applications/PackWise.app`.
3. **C · Legacy build** — same `build` without `-destination` (classic product layout).

Whichever wins, it is **validated**: `Payload/PackWise.app/PackWise` must exist, be non-empty, be arm64 (`file`), carry the iOS device platform (`otool -l` → `LC_BUILD_VERSION platform 2`, never 7 = simulator); any `x86_64` slice is stripped via `lipo -thin arm64`. Then:
4. **Strip test injection** — `PlugIns/*.xctest`, `_CodeSignature`, `SC_Info`, and every XCTest/XC*/Testing framework or dylib are removed from the staged bundle.
5. **Package** — `ditto -c -k --sequesterRsrc --keepParent Payload PackWise-unsigned.ipa` (zip fallback on non-macOS).
6. **Publish gate** — the `.ipa` MUST pass `unzip -t`, contain `Payload/PackWise.app/PackWise` + `Info.plist`, and contain NO test/signing artifacts, or the build **fails loudly** — nothing broken is ever released. Diagnostics land in `build/diagnostics.txt` (uploaded by CI as `ios-build-diagnostics`).

```bash
# One command — sideload-ready or exactly why not (.ipa, artifact .zip, or folder):
../scripts/verify-ipa.sh ios/build/PackWise-unsigned.ipa

file ios/build/PackWise-unsigned.ipa
unzip -l ios/build/PackWise-unsigned.ipa | grep Payload
shasum -a 256 ios/build/PackWise-unsigned.ipa
```

## Troubleshooting

- **Download was a .zip?** → Use the direct `.ipa` on Releases (`latest` or `dev`), or unzip the artifact zip.
- **Not sure a download is valid?** → `./scripts/verify-ipa.sh <file>` — auto-unwraps GitHub artifact zips and tells you in one line whether it's sideload-ready (and why not, if it isn't).
- **Install fails / Untrusted Developer** → Re-sign via AltStore/Sideloadly, or TrollStore where supported.
- **Vision finds nothing** → Clearer, well-lit photo; on-device Vision is conservative.
- **Build says "no IPA"** → Open the *Build unsigned IPA* step logs — diagnostics + `file` + `unzip -l` always print.
- **Sideloader says "Failed to map …/PackWise: Bad file descriptor"** → you have a pre-fix IPA (it had no executable). Use the latest `dev` build or run `./ios/build.sh` — the executable is now validated before publishing.

## Honesty

No IPA advertised until a workflow has produced it. No TestFlight/App Store without Apple signing + App Store Connect.
