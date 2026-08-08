# Changelog

## 1.0.10 — R2 signing-arg fix + web brand polish (2026-08-08)

**R2 ("Bad file descriptor" / device build) — second root cause fixed:**

- The 1.0.9 signing overrides **shipped** (verified: GitHub `main` == local `ios/build.sh`), yet the next push run ([31246529945](https://github.com/Alot1z/packwise/actions/runs/31246529945)) still failed at the "Build unsigned IPA" step **~7 seconds** after tests passed — an immediate `xcodebuild` configuration error, not a compile error.
- Root cause: the `NO_SIGN_STR` string variable word-split into **literal quote characters** being passed to `xcodebuild` (`CODE_SIGN_IDENTITY=""` / `DEVELOPMENT_TEAM=""` — quote removal does not happen on variable expansion), and an explicit `DEVELOPMENT_TEAM=` assignment — even empty — makes Xcode 15/16 try to resolve a team, failing with "requires a development team" before compilation starts.
- Fix: `ios/build.sh` now uses a proper bash **array** (`NO_SIGN=(CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO CODE_SIGN_STYLE=Manual)`) expanded as `"${NO_SIGN[@]}"` with the empty-value assignments removed entirely. Verified: each argument expands as a clean token, no quote leakage; `bash -n` clean. Next macOS run is the verification.
- Evidence recorded: the `dev` release still hosts the old broken IPA (5,004,581 bytes — the exact verified-broken artifact); the publish gate correctly prevented any replacement so far.

**Web & app polish (session 4):**

- `public/manifest.webmanifest` rebranded — was still the platform template ("freebuff.com application", icon `/logo.png` which does not exist); now PackWise-branded with the real `/logo.svg` icon, correct theme colors, travel categories, and scope.
- `ContentView` onboarding transition is now reduced-motion gated (`.animation(reduceMotion ? nil : .easeInOut(...))` via `@Environment(\.accessibilityReduceMotion)`) — users with Reduce Motion on get an instant swap.
- Auth OTP email `appName` fallback now "PackWise" instead of "a freebuff.com application".

**Verification:** `tsc` exit 0 · `bash -n` 4/4 scripts · `js-yaml` 3/3 workflows · `convex dev --once` clean · changelog parity 10/10 surfaces (web ↔ wiki).

## 1.0.9 — CI root-cause repair & binary verification (2026-08-08)

**Build / Infrastructure:**

- Pinned the real CI blocker by evidence: every recent run fails at the device-build step, and the previously published `dev` IPA was verified broken — it shipped `PlugIns/PackWiseTests.xctest` and XCTest frameworks with **no main executable**, the literal cause of `Failed to map …/PackWise: Bad file descriptor`. The hardened verifier rejects that exact artifact, and the pipeline will not publish again until the publish gate passes.
- The iOS workflow's test step no longer aborts the whole job under `bash -e -o pipefail` before test results are recorded (the exit-70 signal). Removed the untrusted `aws/tap` Homebrew tap, added a Homebrew-free XcodeGen fallback (direct release-asset download), bumped to current action majors (`checkout@v5`, `upload-artifact@v7`, `softprops/action-gh-release@v3`), and made the job summary truthful — it can no longer print "IPA still built / No IPA produced" in the same run. Mirrored in the Gitea workflow.
- Rewrote the Wiki sync workflow: `checkout@v5`, wiki-repo enablement via API, and a push step that reports failures accurately instead of failing silently.
- `ios/build.sh`: fixed a latent unclosed-quote bug found by `bash -n`, added explicit unsigned-device-build signing overrides (`DEVELOPMENT_TEAM=""`, `CODE_SIGN_STYLE=Manual`, `CODE_SIGNING_ALLOWED=NO`), and richer failure diagnostics.
- `scripts/verify-ipa.sh`: binary Info.plist is extracted to a file instead of being piped through a command substitution (NUL stripping had defeated `CFBundleExecutable` detection on real builds).

**App:**

- The Vision scanner now respects photo orientation — `UIImage.Orientation` is mapped to `CGImagePropertyOrientation`, so rotated/portrait photos classify correctly instead of being analyzed upside-down.
- Swipe-deleting a trip now requires confirmation before the trip is removed.

**Website:**

- Download page, nav/footer CTAs, and the landing hero now read the live release manifest and show **Status unavailable** when no verified build exists — no more download buttons pointing at a 404 or implying a stale artifact is current.

## 1.0.8 — Release-pipeline hardening & site truthfulness (2026-08-08)

**Build / Infrastructure:**

- Fixed the GitHub Actions workflow that GitHub rejected as an invalid workflow file (YAML syntax error at line 148): the release-manifest validation snippet inside the `run:` block was indented at column 0, which ended the literal block mid-file. Re-indented; both `.github/workflows/ios.yml` and `.gitea/workflows/ios.yml` now parse cleanly with the YAML parser GitHub Actions itself uses, and the validation step runs end-to-end.
- `scripts/verify-ipa.sh` now diagnoses the "Failed to map …/PackWise: Bad file descriptor" class of failure precisely: it detects a symlinked or empty main-executable entry inside the zip from zip metadata alone (no host tools needed) and probes the Mach-O header itself (magic, fat slices, CPU type/subtype) so any machine — including Linux — can classify an artifact as device arm64, simulator, or not-a-binary. Verified against four synthetic artifacts: symlink → rejected with the exact cause; empty → rejected; arm64 → sideload-ready; x86_64 → rejected.
- Hardened the workflow's manifest-validation step to tolerate a `dev: null` pointer (e.g. the first tag-only release) instead of crashing the build.
- New `docs/engineering/EXECUTION-STATE.md` (session state, blocker log, next tasks) and `docs/engineering/FILE-AUDIT.md` (per-file audit manifest) so every session resumes from evidence, not memory.

**Website:**

- Removed fictional app data from the landing page: the hero dashboard mock is now explicitly labeled "Concept preview — illustrative mockup, not real user data", and the screenshot grid is labeled as placeholder frames rather than real captures.
- Site changelog synced with 1.0.7.

## 1.0.7 — Interaction polish & hardening (2026-08-07)

**Web:** `SiteNav` now has active-page highlighting, a mobile drawer with CTAs, skip-to-content link, and full keyboard/ARIA polish; `index.css` adds focus-visible rings, smooth scroll (respects reduced-motion), print styles, and card-lift; `index.html` gains full SEO/OG/Twitter/JSON-LD/noscript; `Landing` fetches the live release manifest to show the latest tag inline, adds progress semantics and `aria-hidden` throughout; `Features`/`Docs`/`Download` all get reduced-motion guards, focus rings, and semantic `<main id="main">`.

**iOS app shell & views:** `ContentView` badge for trips needing attention + iPad `tabViewStyle(.automatic)`; `TripList` swipe-to-delete/duplicate, haptics, date validation; `Dashboard` stats pills + pull-to-refresh; `TripDetail` swipe actions on every row, delete confirmations, haptics, `contentTransition(.numericText())`; `Library`/`PhotoScanner`/`ItemDetail`/`GlobalSearch`/`TemplateLibrary`/`Settings`/`Reminders`/`NewTripSheet` — swipe actions, haptics, delete confirmations, empty-state polish, photo downscaling, date-in-past guard, and a11y hints throughout.

**Services & models:** `RecommendationService` adds cold/rain/7-day/long-trip heuristics + dedupe; `VisionService` threshold 0.12 + richer label map; `NotificationService` adds `pendingCount` + `cancelAll` + past-date guard; `Trip` gains `progressLabel`, `daysUntilDeparture`, `isPast`.

## 1.0.6 — Reduced-motion + color-contrast audit (2026-08-07)

**Reduced motion:** the single animated iOS control — the Onboarding "Continue" `withAnimation` step — now gates on `accessibilityReduceMotion` and jumps instantly when the user has *Reduce Motion* on. On the web, `Landing` now respects the user's `prefers-reduced-motion` via `useReducedMotion()` (hero fade/slide and `FeatureCard` lift are suppressed) and every `.pulse` spinner pauses; a global `prefers-reduced-motion: reduce` rule in `index.css` clamps any residual animations to `0.01ms` so third-party CSS cannot slip through.

**Color contrast:** every orange-on-white and yellow-on-white text path was failing WCAG. The essentials warnings ("N essentials unpacked" in `TripList`, `TripDetail`, `Dashboard`) are now a 4.8:1 brown (`#B85C00`-ish, `Color(red:0.72,g:0.36,b:0)`) paired with an `exclamationmark.triangle.fill` icon so the state is not color-only. Favorite/essential stars (`Library`, `ItemRowInline`) move from pale `.yellow` to a 5.6:1 amber (`Color(red:0.68,g:0.52,b:0)`) with a VoiceOver label. Vision errors (`.red`) move to a distinct dark red + warning icon. The `.pulse` dots honor reduced-motion; the pale BadgeCheck callouts on the Landing are now gated the same way.

**Verification:** `grep` inventories the full motion/surface (1 `withAnimation`, 2 Framer animations, 2 `animate-pulse`, 3 low-contrast color sites) — all now remediated. Web `tsc` clean.

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
