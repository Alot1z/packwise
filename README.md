# PackWise — Your trips, on device.

<p>
  <a href="https://github.com/Alot1z/packwise/releases"><img alt="Releases" src="https://img.shields.io/github/v/release/Alot1z/packwise?label=Releases&color=8b5a2b"></a>
  <a href="https://github.com/Alot1z/packwise/actions/workflows/ios.yml"><img alt="iOS build" src="https://github.com/Alot1z/packwise/actions/workflows/ios.yml/badge.svg"></a>
  <img alt="Platform" src="https://img.shields.io/badge/iOS%20%2B%20iPad-17%2B-black">
  <img alt="License" src="https://img.shields.io/badge/license-MIT-warm">
</p>

> **Private by design.** PackWise is a premium, native iOS packing assistant. Everything — trips, lists, photos, outfits, reminders — lives **on your iPhone**, works **offline**, and never requires an account or a cloud.

**Download → [Latest Release · PackWise-unsigned.ipa](https://github.com/Alot1z/packwise/releases/latest)** · **How to install ↓** · Built free on GitHub Actions `macos-15` + Xcode 16

---

## For everyone — no tech needed

### What PackWise does

| Trips | Packing lists | Outfits & photos |
|---|---|---|
| Destination, dates, activities, climate, notes. Duplicate any trip. | Categories (Clothing, Electronics, Toiletries, Documents…), quantities, essentials, progress. Search, sort, filter. | Scan a photo — PackWise suggests items **on device** → you confirm. Plan outfits day-by-day from what you packed. |

Dashboard shows upcoming trips, packing progress, missing essentials, and quick actions — all local.

### Where your data lives

On your iPhone. Not on our servers — we don’t have servers for your trips. SwiftData stores everything locally, works in airplane mode, and survives app restarts. No login required. No tracking.

### What you need

An iPhone or iPad on iOS 17 or later. That’s it. To install without the App Store you’ll use **AltStore**, **Sideloadly**, or **TrollStore** (where compatible) — each re-signs the app on your device/PC. See install steps below.

---

## Install in 3 steps

> The IPA is **unsigned** — your sideload tool re-signs it on install. This is normal for open-source iOS apps.

**1 · Download the IPA**
Go to **[Releases → Latest](https://github.com/Alot1z/packwise/releases/latest)** and download `PackWise-unsigned.ipa`. Or from any green Actions run: **Actions → iOS — PackWise → PackWise-unsigned-ipa** artifact.

**2 · Open your sideload tool**

- **AltStore:** Install AltServer on Mac/PC → connect iPhone → open AltStore → *My Apps* → **+** → select the IPA.
- **Sideloadly:** Drag the IPA onto Sideloadly, enter your Apple ID for local signing, click Start.
- **TrollStore** (supported versions only): Open TrollStore → **+** → select the IPA — no re-sign needed.

**3 · Trust & open**
On iPhone: *Settings → General → VPN & Device Management* → trust the developer, then open PackWise. Done.

> **No Releases yet?** Push to `main` or run the workflow manually and the first IPA will appear as an artifact, then as a Release when you push a `v*` tag.

---

## Features (everything is inside the IPA)

- **Trips:** create, edit, delete, dates, destination, activities, climate, category, history, duplicate, templates
- **Smart packing lists:** categories, qty, packed/unpacked, progress, search/sort/filter, five starter templates (Weekend, Business, Beach, Hiking, International) + custom
- **Personal item library:** photos, notes, category, favorites, reuse across trips
- **Vision Scanner:** import or scan a photo → on-device `Vision` (no cloud) → **you confirm** before anything is added
- **Outfit Planner:** outfits from packed items, assigned to trip days
- **Dashboard:** upcoming, progress, missing essentials, recent activity
- **Search:** trips, items, outfits, library, templates — offline
- **Reminders:** local notifications for packing and trip prep

No browser packing. No cloud AI. The website is docs — the IPA is the app.

---

## Honesty note

- We never claim an IPA is downloadable until a workflow has actually produced it.
- We never claim TestFlight or App Store — that requires Apple Developer signing and App Store Connect processing.
- Unsigned IPAs are not App Store signed — that’s why you re-sign in AltStore/Sideloadly.

---

## For developers

<details>
<summary><strong>Build from source (click to expand)</strong></summary>

```bash
# Prereqs: Xcode 16+, iOS 17+, Swift 5.9
brew install xcodegen

cd ios
xcodegen generate
open PackWise.xcodeproj          # or run:
xcodebuild test -project PackWise.xcodeproj -scheme PackWise \
  -destination "platform=iOS Simulator,name=iPhone 16,OS=latest" CODE_SIGNING_ALLOWED=NO

./ios/build.sh                   # → ios/build/PackWise-unsigned.ipa
# also: ios/build/PackWise-unsigned.ipa.sha256
```

CI produces the **same** artifact on every host — GitHub Actions (`macos-15`), Gitea Actions (`macos`), or local `act`:

```bash
brew install act
act -W .github/workflows/ios.yml -P macos-15=-self-hosted

# Gitea: enable [actions] in app.ini, add a macOS runner labeled `macos`,
# mirror the repo — .gitea/workflows/ios.yml is the same build.
```

Tag a release to publish automatically:

```bash
git tag v1.0.0 && git push origin v1.0.0
# → GitHub Release with PackWise-unsigned.ipa attached
```

See `ios/README.md` and `docs` on the site for architecture, troubleshooting, and the full build log explanation.

</details>

### Tech at a glance

Swift + SwiftUI · SwiftData · Vision + VisionKit · Photos + Camera · UserNotifications · WidgetKit optional · MVVM + `Services/` · XcodeGen · Fully offline

### Project layout

```
ios/                  # Native iOS app — the product
  PackWise/           # SwiftUI app (Models, Views, Services)
  PackWiseTests/      # Unit / model / persistence tests
  PackWiseUITests/    # UI tests
  project.yml         # XcodeGen spec → PackWise.xcodeproj
  build.sh            # Reproducible unsigned IPA (archive + fallback)
src/                  # Docs website only (Vite + Tailwind)
.github/workflows/    # GitHub Actions — free macOS build
.gitea/workflows/     # Gitea Actions — self-hosted mirror
.actrc                # act — local self-hosted
```

---

## Open source

MIT — free to build, fork, and self-host. No paid APIs, no data collection. Contributions welcome via PRs.

- **Issues:** https://github.com/Alot1z/packwise/issues
- **Releases:** https://github.com/Alot1z/packwise/releases
- **Actions:** https://github.com/Alot1z/packwise/actions

*PackWise is an original implementation inspired by on-device packing workflows. No proprietary assets, branding, or code from the reference app are used.*
