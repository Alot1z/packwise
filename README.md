# 🧳 PackWise — Your trips, on device.

![PackWise — Programmatic 3D Isometric Packing Layers](assets/packwise-hero.svg)

<p>
  <a href="https://github.com/Alot1z/packwise/releases"><img alt="Releases" src="https://img.shields.io/github/v/release/Alot1z/packwise?label=Releases&color=8b5a2b"></a>
  <a href="https://github.com/Alot1z/packwise/actions/workflows/ios.yml"><img alt="iOS build" src="https://github.com/Alot1z/packwise/actions/workflows/ios.yml/badge.svg"></a>
  <a href="https://github.com/Alot1z/packwise/wiki"><img alt="Wiki" src="https://img.shields.io/badge/docs-Wiki-1e140f"></a>
  <img alt="Platform" src="https://img.shields.io/badge/iOS%20%2B%20iPad-17%2B-black">
  <img alt="License" src="https://img.shields.io/badge/license-MIT-warm">
  <img alt="Art" src="https://img.shields.io/badge/art-programmatic%20SVG-fde68a">
</p>

> **Private by design.** PackWise is a premium, native iOS packing assistant. Every trip, packing list, photo, outfit, template and reminder lives **on your iPhone**, works **fully offline**, and never requires an account, a cloud, or an external AI. The IPA is the product — everything else in this repository only documents it.

**Download → [Latest Release · `PackWise-unsigned.ipa`](https://github.com/Alot1z/packwise/releases/latest)** · **Auto-updating dev build → [`dev` · direct .ipa](https://github.com/Alot1z/packwise/releases/tag/dev)** · Built free on `macos-15` + Xcode 16 · Art in `assets/` is 100% programmatic SVG.

---

## 🚀 The 30-second story (no tech needed)

PackWise helps you **stop forgetting things** when you travel. You create a trip, tick off what you packed, snap a photo of anything and let **on-device Vision** suggest items — and PackWise remembers what you always forget: chargers, adapters, essentials. Everything stays on your phone. No sign-up. No Wi-Fi needed. No data leaves your device.

This repository gives you **three things in one**:

| What | Where | Who it's for |
|---|---|---|
| **The app** (`.ipa`) | [Releases](https://github.com/Alot1z/packwise/releases) — build it or download a build | iPhone users |
| **The manual** (deep docs) | [📖 Wiki](https://github.com/Alot1z/packwise/wiki) — 8 pages | Everyone |
| **The live site** (interactive) | Freebuff preview — links, setup wizard, live build status | Everyone |

They're one system, not copies — see [One docs system, three surfaces](#-one-docs-system-three-surfaces).

---

## ⚠️ Got a `.zip` when you expected an `.ipa`?

**This is GitHub's artifact wrapping — not a PackWise bug.** Action downloads always arrive inside an outer `.zip` container. The real `PackWise-unsigned.ipa` (which is a zip of `Payload/PackWise.app` — Apple's spec) is inside.

| Source | What you download | How to get the `.ipa` |
|---|---|---|
| **Releases → Latest / dev** | `PackWise-unsigned.ipa` **directly** — 1 click, no unwrap | Click **Assets → PackWise-unsigned.ipa** |
| **Actions → artifact** | `PackWise-unsigned-ipa.zip` (container) | Download → **unzip once** → `.ipa` inside |

> From this update forward, **every push to `main` publishes a `dev` prerelease** (`releases/tag/dev`) with the direct `.ipa` — you never have to unwrap the artifact if you don't want to. Tags `v*` still create versioned Releases.

Verify any IPA:

```bash
file PackWise-unsigned.ipa            # → Zip archive data (correct — .ipa IS a zip)
unzip -l PackWise-unsigned.ipa | head # → Payload/PackWise.app/ ...
shasum -a 256 PackWise-unsigned.ipa
```

---

## 📲 Install in 3 steps — no tech needed

> The IPA is **unsigned** — your sideload tool re-signs it locally on your own Apple ID. This is completely normal for open-source iOS apps.

**1 · Download the app**
[Releases → Latest](https://github.com/Alot1z/packwise/releases/latest) → `PackWise-unsigned.ipa`. Prefer always-fresh? → [`dev` · latest main](https://github.com/Alot1z/packwise/releases/tag/dev).

**2 · Open it with a sideload tool**

<details>
<summary><strong>AltStore</strong> — the friendliest option</summary>

1. Install [AltServer](https://altstore.io) on a Mac or PC.
2. Connect your iPhone to the same computer (Wi-Fi or cable).
3. Open **AltStore** on your iPhone → **My Apps** → tap **+** → select the `.ipa`.
4. AltStore re-signs it with your Apple ID and installs it.

</details>

<details>
<summary><strong>Sideloadly</strong> — works on Windows and macOS</summary>

1. Install [Sideloadly](https://sideloadly.io).
2. Drag the `.ipa` onto the window.
3. Enter your Apple ID (it is only used to sign locally), hit **Start**, and wait for the install.

</details>

<details>
<summary><strong>TrollStore</strong> — no re-signing at all (where supported)</summary>

Open **TrollStore** → **+** → select the `.ipa`. Done — no Apple ID needed on supported iOS versions.

</details>

**3 · Trust & open**
*Settings → General → VPN & Device Management* → tap your developer profile → **Trust** → open PackWise. ✈️

> Transfer the `.ipa` to your iPhone via AirDrop, Files, or a computer, then open it in your sideload tool. iOS 17 or later required.

---

## ✅ Verified build status — inspected, not assumed

We don't claim a working IPA until a build has been **inspected byte-for-byte**. Here's what we check on every published artifact:

| Check | Why it matters |
|---|---|
| `Payload/PackWise.app/PackWise` exists, non-empty | A missing executable is exactly the `Failed to map …/PackWise: Bad file descriptor` sideload failure |
| Binary is **arm64 device** Mach-O (`LC_BUILD_VERSION platform 2`, never 7 = simulator) | Simulator binaries cannot run on a physical iPhone |
| **No test bundles** (`*.xctest`, `XCTest`/`XCUnit`/`XCUIAutomation`/`Testing` frameworks) | Test injection bloats the app and breaks sideloading |
| `unzip -t` integrity + `shasum -a 256` published alongside | You can verify your download matches |

The pipeline **refuses to publish** anything that fails these checks — a broken build fails loudly with readable diagnostics (also uploaded as the `ios-build-diagnostics` artifact so anyone can read why).

```bash
# Inspect the current dev build right now:
curl -L -o PackWise.ipa https://github.com/Alot1z/packwise/releases/download/dev/PackWise-unsigned.ipa
unzip -l PackWise.ipa | grep -E "Payload/PackWise.app/(PackWise|Info.plist)"   # both must appear
shasum -a 256 PackWise.ipa   # compare with the .sha256 asset on the same release
```

---

## 🎒 What's inside the IPA — everything on device

![PackWise Architecture — On Device Pipeline](assets/architecture.svg)

**Trips** — title, destination, dates, activities, climate, status (`planning`/`packing`/`ready`/`archived`), duplicate, apply templates ·
**Lists** — Clothing / Electronics / Toiletries / Documents / Medical / Accessories / Outdoor + custom categories, quantities, essentials, packed state, live progress, search/sort/filter ·
**Library** — reusable personal items with photos, notes, favorites ·
**Vision Scanner** — on-device `VNClassifyImageRequest`: photo → suggestions → **you confirm** before anything is added. No cloud, no silent changes ·
**Outfits** — day-by-day outfit planning from packed items ·
**Dashboard** — upcoming trips, packing progress, missing essentials ·
**Search** — trips, items, outfits, templates — fully offline ·
**Templates** — Weekend, Business, Beach, Hiking, International + custom ·
**Reminders** — local `UserNotifications`, no servers.

No browser packing. No cloud AI. No telemetry. The site is docs — the IPA is the app. Full field-level detail → [Wiki → Features](https://github.com/Alot1z/packwise/wiki/Features).

---

## 🏗 Architecture — native, offline, testable

```mermaid
flowchart TB
    UI[SwiftUI Views<br/>Dashboard · Trip Detail · Scanner] --> VM[Services · ViewModels<br/>VisionService · Recommendation · Notifications]
    VM --> M[SwiftData Models<br/>Trip · PackingItem · PersonalItem · Outfit]
    M --> S[(On-Device Store<br/>SwiftData · offline · migrations)]
    P[Photos + Camera] --> V[Vision<br/>VNClassifyImageRequest]
    V --> VM
    N[UserNotifications] --> VM
    S --> UI
    style UI fill:#fff,stroke:#c9b9a6
    style VM fill:#f5ece0,stroke:#8b5a2b
    style M fill:#eef2ff,stroke:#1e1b4b
    style S fill:#1e140f,color:#fff,stroke:#1e140f
```

**Stack:** Swift + SwiftUI · SwiftData · Vision + VisionKit · Photos + Camera · UserNotifications · MVVM + `Services/` · XcodeGen · iOS 17+

**Navigation (no dead screens):** Launch → Onboarding → **Dashboard** → **Trips** → **Trip Detail** → **Item Detail** → **Scanner** → **Outfit** → **Library** → **Search** → **Templates** → **Reminders** → **Settings** · Light/Dark · Dynamic Type · VoiceOver · iPhone + iPad

→ [Wiki → Architecture](https://github.com/Alot1z/packwise/wiki/Architecture) · [Wiki → Data Models](https://github.com/Alot1z/packwise/wiki/Data-Models) · [Wiki → Vision & Privacy](https://github.com/Alot1z/packwise/wiki/Vision-and-Privacy)

---

## 🔗 One docs system, three surfaces

The README, the Wiki, and the live site are **the same documentation rendered three ways** — no copy-paste drift:

| Surface | What it's for | Link |
|---|---|---|
| **README** | Splash + 30-second install — 3D art, quick start, FAQ | You are here |
| **Wiki** | Deep, versioned docs — architecture, Vision internals, build logs, troubleshooting | [`Alot1z/packwise/wiki`](https://github.com/Alot1z/packwise/wiki) |
| **Live Preview Site** | Interactive landing, setup wizard, live build status — links straight to the same Releases | `src/` → Vite build |

```mermaid
flowchart LR
    A[assets/*.svg — art is code] --> R[README.md]
    R --> W[wiki/*.md → Alot1z/packwise.wiki.git]
    W --> S[Live Site — Landing + Setup]
    G[GitHub Actions macos-15] -->|PackWise-unsigned.ipa + dev + v* Release| R
    G -->|badge| R
```

- Push to `main` → `ios.yml` builds & validates the IPA → publishes **artifact** + **`dev` prerelease** (direct `.ipa`) → `wiki.yml` syncs `wiki/` to the Wiki
- Tag `v*` → versioned Release with the same `.ipa`
- The live site imports `assets/*.svg` and links to the same `releases/latest`, `releases/tag/dev`, and `actions` URLs — one source of truth

---

## 🖼 Art is code

No screenshots. Every visual in this README is a **hand-written SVG** in `assets/` — diffable, scalable, no binary exports:

| Art | File | Shows |
|---|---|---|
| Isometric suitcase — 3 floating layers | [`assets/packwise-hero.svg`](assets/packwise-hero.svg) | Clothing (62%) → Vision on-device → Outfit Day 2 |
| Pipeline diagram | [`assets/architecture.svg`](assets/architecture.svg) | SwiftUI → Services → SwiftData → On Device |
| Social card | [`assets/og-image.svg`](assets/og-image.svg) | 1200×630 `og:image` |

Gradients, shadows and isometric projection are math (`viewBox`, `linearGradient`, `filter: dropShadow`) — edit the SVG to change the art.

---

## 👩‍💻 For developers — build from source (reproducible)

<details>
<summary><strong>Quick build</strong></summary>

```bash
brew install xcodegen
cd ios && xcodegen generate && open PackWise.xcodeproj

# Tests (non-blocking in CI — the IPA still builds if tests flake)
xcodebuild test -project PackWise.xcodeproj -scheme PackWise \
  -destination "platform=iOS Simulator,name=iPhone 16,OS=latest" CODE_SIGNING_ALLOWED=NO

# Unsigned IPA — same self-healing pipeline as CI
./ios/build.sh   # → ios/build/PackWise-unsigned.ipa + .sha256
file ios/build/PackWise-unsigned.ipa && unzip -l ios/build/PackWise-unsigned.ipa | head
```

</details>

**Three equal hosts — same validated artifact** (`Payload/PackWise.app` → `PackWise-unsigned.ipa`):

```bash
# 1) GitHub Actions — no Mac needed on your side
git push origin main                          # → artifact + dev prerelease (direct .ipa)
git tag v1.0.0 && git push origin v1.0.0      # → versioned Release

# Direct download without unwrapping (after a main push):
gh release download dev -R Alot1z/packwise -p "PackWise-unsigned.ipa"

# 2) Gitea Actions — self-hosted FOSS (same YAML, runs-on: macos)
git remote add gitea https://YOUR_GITEA/YOU/packwise.git && git push gitea main

# 3) act locally — fully offline after clone (Mac + Xcode required)
brew install act
act -W .github/workflows/ios.yml -P macos-15=-self-hosted
```

> **Why three build strategies?** Xcode 16 with `CODE_SIGNING_ALLOWED=NO` can exit 0 while emitting an app bundle *without the main executable* (or with test bundles injected) — the exact cause of the old “Bad file descriptor” sideload failure. `ios/build.sh` therefore tries **device build → archive → legacy build**, validates the executable (exists, non-empty, arm64, `platform 2`), strips test injection, and **refuses to publish** anything that fails the gate. Diagnostics are always written to `ios/build/diagnostics.txt` and uploaded by CI.

→ [Wiki → Build & Release](https://github.com/Alot1z/packwise/wiki/Build-and-Release) · [`ios/README.md`](ios/README.md) · Live logs: [`Actions`](https://github.com/Alot1z/packwise/actions)

### Project layout

```
assets/               # 3D SVGs — art is code
ios/                  # Native iOS app — the product
  PackWise/           # SwiftUI app (App, Models, Services, Views)
  PackWiseTests/ · PackWiseUITests/
  Resources/Assets.xcassets/AppIcon.appiconset/  # programmatic 1024px icon
  project.yml         # XcodeGen → PackWise.xcodeproj
  build.sh            # Self-healing IPA: build → archive → legacy + strict gate
scripts/              # generate-appicon.py — the icon is code too
wiki/                 # Wiki source — synced to Alot1z/packwise.wiki
src/                  # Live docs site only (Vite + Tailwind) — not the app
.github/workflows/    # ios.yml (build+release) + wiki.yml (docs sync)
.gitea/workflows/     # Mirror for Gitea Actions
```

### Live docs site

```bash
bun install && bun run build   # → dist/ (deploy to Pages/Netlify/any static host)
```

---

## ❓ FAQ

**Do I need an Apple Developer account?** No. The unsigned IPA is built for you by CI, and your sideload tool signs it with your own Apple ID at install time.

**Does PackWise send my data anywhere?** No. No account, no cloud, no analytics, no tracking. Vision runs on-device; reminders are local; everything is in SwiftData on your phone.

**Why is it called “unsigned”?** It isn't signed by Apple, so iOS won't install it by default — a sideload tool (AltStore/Sideloadly/TrollStore) handles signing locally. This is how nearly all open-source iOS apps are distributed.

**The app needs re-installing after 7 days?** Free Apple ID sideloads (AltStore/Sideloadly) refresh automatically while your Mac/PC is reachable. TrollStore installs (where supported) are permanent.

**Can I build it myself?** Yes — any Mac with Xcode 16+; see the developer section. No proprietary dependencies.

**Is the iPad supported?** Yes — iPhone and iPad (TARGETED_DEVICE_FAMILY 1,2).

**Will there be an App Store version?** Only if you sign it with your own Apple account and submit it to App Store Connect — this repo does not claim TestFlight/App Store distribution.

---

## 🛠 Troubleshooting

- **Downloaded a `.zip`?** → That's the artifact container. The direct `.ipa` is on [Releases Latest](https://github.com/Alot1z/packwise/releases/latest) or [`dev`](https://github.com/Alot1z/packwise/releases/tag/dev). If you used the artifact, unzip it once.
- **“Failed to map …/PackWise: Bad file descriptor”?** → You sideloaded a pre-fix build that had no executable. Download the latest [`dev`](https://github.com/Alot1z/packwise/releases/tag/dev) build — the executable is now validated before every publish.
- **Install fails / Untrusted Developer** → Re-sign via AltStore/Sideloadly, or use TrollStore where supported; then *Settings → General → VPN & Device Management* → Trust.
- **No IPA artifact?** → Open the *Build unsigned IPA* step logs or the `ios-build-diagnostics` artifact — diagnostics + `unzip -l` always print.
- **Vision finds nothing** → Clearer, well-lit photo; on-device Vision is intentionally conservative.

Full → [Wiki → Troubleshooting](https://github.com/Alot1z/packwise/wiki/Troubleshooting)

---

## 📜 Honesty

- No IPA advertised until a workflow has produced **and validated** it.
- No TestFlight / App Store claimed — that requires Apple signing + App Store Connect.

## 🧾 Open source

MIT — no paid APIs, no data collection. Art in `assets/` and the app icon are original, programmatically generated.

- **Issues:** https://github.com/Alot1z/packwise/issues · **Releases:** https://github.com/Alot1z/packwise/releases · **Actions:** https://github.com/Alot1z/packwise/actions · **Wiki:** https://github.com/Alot1z/packwise/wiki
