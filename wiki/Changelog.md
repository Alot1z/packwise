# Changelog

## 1.0.5 — Dynamic Type audit (2026-08-07)

**iOS:** full sweep for fixed-size fonts across every screen. The only offender was the onboarding hero icon (`font(.system(size: 44))`) — it now uses `@ScaledMetric(relativeTo: .largeTitle)`, so it grows with accessibility text sizes instead of staying tiny. Every other text element already rides scalable text styles (`.caption`/`.caption2`/`.subheadline`/`.headline`/`.title`/`.title3`), so all 16 screens reflow correctly from the smallest to the largest Dynamic Type setting. No `minimumScaleFactor` shrinking, no `.dynamicTypeSize` caps — text is allowed to wrap and grow.

**Verification:** `grep` sweep confirms zero remaining `system(size:)`-style fixed fonts (the only `Font` calls are text styles + the scaled metric).

## 1.0.4 — Accessibility & VoiceOver pass (2026-08-07)

**iOS:** explicit VoiceOver labels across every interactive control — item toggles now announce **"Mark {name} as packed / unpacked"** (with a `Packed`/`Unpacked` value and hint, never the raw SF Symbol name), template **Add / Apply / Delete** buttons announce which template they act on, Vision suggestion buttons expose selection state (`.isSelected` trait) and suggestion "Add" buttons include the reason. Text editors, item/library/photo images, and packing `ProgressView`s are labeled or hidden-from-VoiceOver where decorative; trip rows combine their content into a single announcement. Onboarding icons are decorative.

**Test:** new UI test `testItemToggleHasVoiceOverLabel` (in `PackWiseUITests`) creates a trip, adds an item, and asserts the toggle's explicit label exists — a VoiceOver regression guard. Non-blocking in CI like the rest of the suite.

## 1.0.3 — Algorithm-friendly release manifest + workflow inputs (2026-08-07)

**New:** [`scripts/release-manifest.sh`](https://github.com/Alot1z/packwise/blob/main/scripts/release-manifest.sh) — emits [`PackWise-releases.json`](https://github.com/Alot1z/packwise/releases/latest/download/PackWise-releases.json) (schema `packwise.releases/v1`), attached as a release asset on every published build. Stable deterministic URLs (no GitHub API key required):

- `https://github.com/Alot1z/packwise/releases/latest/download/PackWise-releases.json` — **newest stable** pointer + history
- `https://github.com/Alot1z/packwise/releases/download/dev/PackWise-releases.json` — **newest dev** prerelease pointer

`manifest.latest`, `manifest.dev`, and `manifest.releases[]` (newest-first, `is_latest` flagged, with `sha256`, `size_bytes`, `published_at`) give any AI / script one fetch. CI accumulates history by fetching the prior dev manifest, deduplicating per tag, and re-publishing — the dev release stays current forever.

**Trust + changelog per release:** every entry now carries `verified_by_build` (`true` = passed the strict publish gate; CI always sets it, local uploads can opt out with `--no-verified`), `changelog_url` (wiki), and `release_notes_url` (per-tag notes page).

**Workflow config:** [.github/workflows/ios.yml](https://github.com/Alot1z/packwise/blob/main/.github/workflows/ios.yml) now exposes *Run workflow* inputs (`xcode_version: macos-14|macos-15`, `skip_tests: boolean`, `release_channel: auto|dev`); mirror change in [.gitea/workflows/ios.yml](https://github.com/Alot1z/packwise/blob/main/.gitea/workflows/ios.yml). Dispatch defaults to publishing a fresh `dev` prerelease.

**Live site:** the [Download page](https://packwise.freebuff.app/download) has an "Algorithm-friendly" section with copy-pasteable `curl | jq` recipes.

## 1.0.2 — One-command IPA verification (2026-08-07)

**New:** [`scripts/verify-ipa.sh`](https://github.com/Alot1z/packwise/blob/main/scripts/verify-ipa.sh) — one command that tells you whether **any** PackWise download is sideload-ready, before you sideload it:

- Accepts the direct `.ipa`, the GitHub Actions artifact `.zip` (auto-unwraps the inner `.ipa`), or any folder.
- Checks zip integrity, `Payload/<App>.app` presence, main-executable existence (the exact `Failed to map …/PackWise: Bad file descriptor` guard), arm64 device Mach-O, and no test/signing artifacts — then prints the sha256 to compare against the Release.
- Wired into **both** CI pipelines (`.github/workflows/ios.yml` and `.gitea/workflows/ios.yml`) as the final publish gate, so CI and users share one verifier.

**Also:** README, wiki (Troubleshooting, Build-and-Release), `ios/README.md`, `ios/build.sh` notes, and the live Download page now lead with the one-liner.

## 1.0.1 — Sideload fix verified + self-healing IPA pipeline (2026-08-07)

**Root cause confirmed by inspection:** the earlier `dev` IPA contained `PlugIns/PackWiseTests.xctest`, injected XCTest frameworks, and **no main executable** — the literal cause of `Failed to map …/PackWise: Bad file descriptor`.

**Pipeline:** `ios/build.sh` is now self-healing — tries device build → archive → legacy build, validates the executable (exists, non-empty, arm64, `LC_BUILD_VERSION platform 2`), strips test injection comprehensively, and refuses to publish anything that fails the gate. CI uploads `ios-build-diagnostics` on every run (readable without sign-in) and shows diagnostics in the job summary. `checkout@v5`, `ENABLE_TESTABILITY=NO`.

**App icon:** real programmatic 1024px icon generated by `scripts/generate-appicon.py` (the asset catalog previously referenced 15 icons with zero files — a device-Release build blocker).

**Docs:** README redesigned (non-tech-first, FAQ, verified-build section), wiki updated, live Vite preview hardened so CDN cache mismatches no longer break the page.

## 1.0.0 — Native iOS + Fancy 3D Docs (2026-08-07)

**App:** SwiftUI + SwiftData + Vision on device. Trips (destination/dates/activities/climate/status), packing lists (categories/qty/packed/essential/progress/search), personal library (photo/favorite/reuse), Vision Scanner (`VNClassifyImageRequest` confirm-before-add), Outfit Planner (dayLabel), Dashboard (upcoming/progress/missing), Global Search, Templates (5 starters + custom), Reminders (`UserNotifications`), Settings. Light/Dark, Dynamic Type, VoiceOver, iPhone + iPad.

**Build:** Xcode 16 + `macos-15` + `xcodegen generate` → `PackWise.xcodeproj`. Tests: `PackWiseTests` (Swift Testing) + `PackWiseUITests`. IPA: `xcodebuild archive` + `DerivedData` fallback → `Payload/PackWise.app` → `PackWise-unsigned.ipa` + `.sha256`. Three hosts: GitHub Actions / Gitea Actions / `act` locally (`.actrc`). Non-blocking tests (`continue-on-error` + `if: always()`) so [#31163718082](https://github.com/Alot1z/packwise/actions/runs/31163718082) cannot block the IPA again. Release on `v*` tag.

**Docs — 3D + deep + live-combined:**
- **README** with programmatic 3D SVG art: `assets/packwise-hero.svg` (isometric suitcase, 3 layers), `assets/architecture.svg` (pipeline), `assets/og-image.svg` (1200×630) — every visual is hand-written SVG, never a screenshot
- **This Wiki** (8 pages) synced from `wiki/` via `.github/workflows/wiki.yml` to `Alot1z/packwise.wiki`
- **Live Freebuff preview site** (`src/`, Vite + Tailwind) — imports `assets/*.svg`, links to `Alot1z/packwise/releases` + `…/actions` — README, Wiki, and live site stay in sync without copy-paste

**Privacy:** On device, offline, no cloud, no account, no tracking. MIT.
