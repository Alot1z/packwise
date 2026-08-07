# PackWise iOS — the app is the product

Native, private, offline. SwiftUI + SwiftData + Vision — everything on device.

> **Get the IPA →** [Releases · Latest](https://github.com/Alot1z/packwise/releases/latest) · or **Actions → iOS — PackWise → PackWise-unsigned-ipa**
> This doc is for building it yourself.

## Quick start

```bash
brew install xcodegen
cd ios
xcodegen generate
open PackWise.xcodeproj
```

Run on simulator or device (no signing needed for the simulator build):

```bash
xcodebuild build -project PackWise.xcodepoj -scheme PackWise \
  -destination "platform=iOS Simulator,name=iPhone 16,OS=latest" CODE_SIGNING_ALLOWED=NO
```

## What's inside

**Models (SwiftData):** `Trip` · `PackingItem` · `PersonalItem` · `Outfit` · `PackCategory` · `PackTemplate` · `Reminder` · `UserPreference` — all local, offline, backup-safe.

**Services:** `VisionService` (on-device `VNClassifyImageRequest`, confirm-before-add) · `NotificationService` (local `UserNotifications`) · `RecommendationService` (rule-based, no cloud).

**Navigation (no dead screens):** Launch → Onboarding → **Dashboard** (upcoming, progress, missing) → **Trips** → **Trip Detail** (list + progress + search) → **Item Detail** → **Photo Scanner** → **Outfit Planner** → **Library** → **Search** → **Templates** → **Reminders** → **Settings**. Light/Dark, Dynamic Type, VoiceOver, iPhone + iPad.

## Tests

```bash
cd ios && xcodegen generate
xcodebuild test -project PackWise.xcodeproj -scheme PackWise \
  -destination "platform=iOS Simulator,name=iPhone 16,OS=latest" CODE_SIGNING_ALLOWED=NO
```

Targets: `PackWise` · `PackWiseTests` (unit/model/persistence) · `PackWiseUITests` (smoke).

## Unsigned IPA — reproducible, three equal hosts

All three produce the **identical** `PackWise-unsigned.ipa` (zip of `Payload/PackWise.app`) for AltStore / Sideloadly / TrollStore.

### 1 — GitHub Actions (no Mac needed on your side)

Push to `main` or `Actions → iOS — PackWise → Run workflow` (free `macos-15` runner, Xcode 16). Artifact `PackWise-unsigned-ipa` is kept 14 days. Tag `v*` also publishes a **GitHub Release**.

```bash
git tag v1.0.0 && git push origin v1.0.0
```

### 2 — Gitea Actions (self-hosted, FOSS)

Same YAML at `.gitea/workflows/ios.yml` (`runs-on: macos`). Enable `[actions]` in `app.ini`, register a **macOS runner** labeled `macos`, push to your Gitea — same artifact. See https://docs.gitea.io/en-us/usage/actions/comparison/

Just mirror — no YAML rewrite:

```bash
git remote add gitea https://YOUR_GITEA/YOU/packwise.git
git push gitea main
```

### 3 — act locally (nektos/act, fully offline after clone)

Requires a Mac with Xcode (Apple restriction — Linux cannot run `xcodebuild`):

```bash
brew install act
act -W .github/workflows/ios.yml -P macos-15=-self-hosted
# or simply:
./ios/build.sh   # → ios/build/PackWise-unsigned.ipa + .sha256
```

`.actrc` at repo root maps `macos-15`/`macos` to `-self-hosted`.

### How the IPA is built (so the "archive produced no .app" error never bites you again)

Xcode 16’s `xcodebuild archive CODE_SIGNING_ALLOWED=NO` sometimes exits empty when`archivearchive/`. script (aut) try `archive` first, then **fallback** to `xcodebuild build -destination generic/platform=iOS -derivedDataPath ...` and find the `PackWise.app` in `DerivedData`. Verification:

```bash
ls -lh ios/build/PackWise-unsigned.ipa
unzip -l ios/build/PackWise-unsigned.ipa | head
shasum -a 256 ios/build/PackWise-unsigned.ipa
```

## Troubleshooting

- **Install fails / Untrusted Developer** — Unsigned IPAs must be re-signed. In AltStore/Sideloadly enter an Apple ID for local signing; in TrollStore just tap + (where supported).
- **Vision suggests nothing** — use a clearer, well-lit photo; Vision is on-device and conservative.
- **Build says "no IPA"** — open the *Archive — unsigned IPA* step logs; the fallback + diagnostics (`find build -type d`, `ls -R build`) will show where the `.app` landed.

## Honesty

No IPA is advertised until a workflow has actually produced it. No TestFlight/App Store claim without real Apple signing and App Store Connect processing.
