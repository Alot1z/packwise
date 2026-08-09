# Changelog

## 1.0.19 — CI caching redesign & XcodeGen spec fix (2026-08-09)

**The real CI blocker, found by inspecting the failing run — plus a warm-cache pipeline.**

- **Root cause fixed:** run [31317701450](https://github.com/Alot1z/packwise/actions/runs/31317701450) failed at **Generate Xcode project** in 0 seconds. The GitHub annotations channel said only "exit code 1", so the step structure was inspected: everything before `xcodegen generate` passed, the step itself died instantly → a spec error, not a compile error. Root cause: `options.entitlements` was placed under `options:` in `ios/project.yml` — XcodeGen's spec rejects unknown option keys (entitlements belong on **targets**). Fixed; entitlements now live only on the `PackWise` and `PackWiseWidget` targets.
- **Removed nonstandard `sdk:` framework dependencies** from the Widget extension target — SwiftUI/SwiftData/WidgetKit are auto-linked by the Swift compiler; declaring them can trip XcodeGen's SDK resolution on newer toolchains.
- **Workflow redesigned for warm CI** (`.github/workflows/ios.yml`):
  - **Parallel jobs:** `web-static-validation` (Ubuntu: bun install → `tsc -b --noEmit` → `vite build` → `bash -n` → `js-yaml`) runs concurrently with the macOS build — web regressions never burn macOS minutes.
  - **Xcode:** runner-provided, selected deterministically (newest installed), recorded (`sw_vers`, `xcodebuild -version`, `xcode-select -p`, `swift --version`, SDKs). Never downloaded.
  - **iOS device platform cache:** keyed by exact Xcode version + arch, restored with sudo, **validated** via `xcodebuild -showsdks`; the official `xcodebuild -downloadPlatform iOS` remains the fallback. A corrupt cache can never conceal a missing platform.
  - **XcodeGen cache:** pinned 2.46.0 in the runner tool cache — the same release is never downloaded twice; the version is still verified on every run.
  - **Bun cache:** lockfile-keyed (`bun-{os}-{hash(bun.lock, package.json)}`), invalidated on any dependency change.
  - **DerivedData / SPM deliberately NOT cached:** the archive always compiles fresh, so stale objects can never hide a source regression. Cache is an optimization layer, never a correctness requirement.
  - **Release chain untouched:** the IPA is always freshly produced by the current commit, passes `verify-ipa.sh`, and only then publishes.
- **Public failure channel extended:** the xcodegen step now emits `::error::` annotations, so any future spec error is readable without sign-in.
- **Gitea mirror updated:** dynamic simulator discovery (replaces hardcoded "iPhone 16") + the same error annotations.
- Docs: `docs/CI.md` rewritten with the caching strategy table and cache-correctness contract.

**Validation:** web `tsc` 0 · `bash -n` 3/3 · `js-yaml` 4/4 (ios.yml, gitea ios.yml, wiki.yml, project.yml). **Pending:** next macOS CI run is the authority — XcodeGen generation must pass, then the iOS-18-targeted Swift must compile, archive, and pass IPA verification.

## 1.0.18 — iOS 18 target, warm design system & scanner polish (2026-08-09)

**iOS 18 minimum, a new visual identity, and a polished scanner.**

- **iOS 18+ deployment target:** bumped from iOS 17 to iOS 18 across all targets (app, widget, tests, UI tests). Swift 5.9 → 6.0, Xcode 15.0 → 16.0. Unlocks modern SwiftUI, SwiftData, and Vision APIs without availability guards.
- **Warm PackWise design system** (`DesignSystem/DesignTokens.swift`, 240+ lines):
  - **Color palette:** terracotta primary (`#EB7352`), deep teal secondary (`#266B6B`), golden amber accent (`#E6A633`), warm off-white backgrounds (`#F7F5F0`), warm dark mode surfaces. No generic blue/purple.
  - **Typography:** serif headings (`.serif` design), default body, monospaced data. All semantic text styles, no fixed sizes.
  - **Spacing:** xs/sm/md/lg/xl/xxl (4–32pt). Controlled, intentional.
  - **Animation:** spring-based — fast (0.3s), standard (0.4s), slow (0.5s), bouncy (0.4s low damping).
  - **Reusable modifiers:** `packWiseCard()` (warm surface + shadow), `packWiseChip()` (colored capsule), `packWiseSectionHeader()` (serif title).
- **Scanner UX polished:**
  - Capture: white flash overlay (150ms fade) on shutter press, bouncy spring animation on the shutter button ring.
  - Transitions: review flow uses opacity + scale animation; Reduce Motion gates on every animation.
  - Live camera framing guide, "Center the item, then capture" hint, flicker-free camera toggle.
- **Redesigned Dashboard:**
  - Warm stat pills (terracotta tint, rounded rect with border stroke).
  - Card-based upcoming trips with progress rings.
  - Recommendations section with amber lightbulb icons, packing progress with accent-tinted bars.
  - Quick action grid (Scanner, Templates, Search, New Trip).
  - Scroll-based layout replacing the old insetGrouped list.
- **TripListView themed:** per-status chip colors (planning=info blue, packing=amber, ready=green, archived=grey), PackWise typography, warm warning colors for essentials.
- **Docs created/updated:**
  - `docs/APPLE-API-CAPABILITY-BIBLE.md` — 60+ verified API symbols across 12 frameworks, every symbol cross-referenced with Xcode 26.3 verification.
  - `docs/UI-UX-DESIGN-SYSTEM.md` — full design principles, color palette, typography scale, spacing, component library, motion system, scanner UX flow, accessibility checklist.

**Validation:** web `tsc` 0 · `bash -n` 3/3 scripts · `js-yaml` 3/3 workflows. **Pending:** the next macOS CI run must compile with the new iOS 18 target, Swift 6.0, and the design system import.

## 1.0.17 — App Intents, Widgets & CI compile fix (2026-08-09)

**Siri shortcuts and home screen widgets arrive — plus the CI compile fix.**

- **CI compile fix:** `SubjectExtractor.swift` used two APIs that don't exist on iOS 17: `.instanceCount` (now `observation.allInstances`, an `IndexSet`) and `generateMaskedImage(ofInstances:croppedToInstancesExtent:)` without the required `from:` parameter (now passes the `VNImageRequestHandler`). The Xcode 26.3 / iOS 26.2 compiler rejected both — this was the real cause of the session-16 CI failure.
- **App Intents (Siri + Shortcuts):** three intents registered via `PackWiseShortcuts` provider:
  - `AddInventoryItemIntent` — "Add socks to my inventory" (name + optional category)
  - `MarkPackedIntent` — "Mark passport as packed" (finds the first unpacked match across all trips)
  - `CreateTripIntent` — "Create a trip to Paris" (title + destination + optional start date)
  All intents use the App Group SwiftData container so they see the same data as the app.
- **Home Screen Widgets**, delivered as a WidgetKit extension (`PackWiseWidget`):
  - `NextTripWidget` (systemSmall + systemMedium) — shows the next upcoming trip, days until departure, and packing progress with a progress bar.
  - `PackingProgressWidget` (systemMedium + systemLarge) — lists up to 5 active trips with destination names, days-away badges, and per-trip progress bars ("3/12 packed").
  - Widgets read the same SwiftData store as the main app via `group.com.packwise` App Group container.
- **Architecture:** the main app now uses `ModelConfiguration(groupContainer:)` with an automatic fallback to the default local store when App Groups are unavailable (unsigned simulator builds). Widget extension embeds in the app bundle; scheme updated to include it in build/archive.

**Validation:** web `tsc` 0 · `bash -n` 3/3 scripts · `js-yaml` 3/3 workflows. **Pending:** the next macOS CI run is the acceptance gate for all three changes (compile fix, App Intents, Widget extension compilation). The Xcode compiler must successfully build the widget extension alongside the main app.

## 1.0.16 — Outfit recommendation engine & destination geocoding fallback (2026-08-09)

**Outfit recommendations arrive — deterministic, weather-aware, item-aware.**

- **Outfit recommendation engine:** `RecommendationService.outfitSuggestions(for:weather:)` generates FullPack-class outfit ideas from trip context (business meetings → blazer/white-shirt, beach → swim-shorts/sandals, outdoor → hiking boots/rain-shell, cold → warm-layers/gloves, international → travel-day), weather conditions, and items already packed. Each suggestion maps named items to a purpose and day label, but **only when every item is already packed** — suggestions that reference absent items are filtered out.
- **Destination geocoding fallback:** when you type a free-text destination (e.g. "Kyoto, Japan") without picking a MapKit completer suggestion, `CLGeocoder` now resolves it to coordinates on trip creation — no more manual lat/lon entry. The `NewTripSheet` Create button waits for the geocoding result before persisting the trip.
- **Tests:** 5 new deterministic offline outfit recommendation tests (`OutfitRecommendationTests`) in `PackWiseTests` (business, beach, rainy-outdoor, international, unpacked-item filtering).
- Docs: `FULLPACK-CAPABILITY-MATRIX.md` outfit row updated (DESIGNED → IMPLEMENTED).

**Validation:** web `tsc` 0 · `bash -n` 3/3 scripts · `js-yaml` 3/3 workflows · Convex codegen OK. **Pending:** the next macOS CI run is the acceptance gate for the new Swift files (Xcode compile + archive + IPA verification).

## 1.0.15 — FullPack-class scanner, background removal & weather-aware packing (2026-08-09)

**The `.searchActions` API never existed — the previous shim wrapped a phantom.**

- **Root cause finally resolved, and the fix is deletion:** Apple's SwiftUI has no `.searchActions` modifier on any OS version. The `SearchClearActionsModifier.swift` wrapper (1.0.13/1.0.14) was wrapping a nonexistent symbol that the Xcode 26.3 / iOS 26.2 SDK compiler rejected with `value of type 'Self' has no member 'searchActions'`. The entire shim is now **deleted**, along with its two callers in `TripListView` and `GlobalSearchView`. iOS 17's `.searchable()` already provides a built-in clear (X) button, so the user experience is unchanged — the compile blocker is simply gone.
- **Real camera scanner:** `CameraService` (`AVCaptureSession` live preview, capture, flip, permission/unauthorized states) + `CameraScannerView` replacing the picker-only `PhotoScannerView` (deleted). Photo-library import remains as a fallback (`PhotosPicker`).
- **Background removal (FullPack-style):** `SubjectExtractor` uses `VNGenerateForegroundInstanceMaskRequest` (iOS 17+) for a transparent cutout + thumbnail, with graceful fallback to the original photo when no subject is found. On-device, offline.
- **Weather-aware packing:** `DestinationSearchService` (`MKLocalSearchCompleter` → coordinate, no manual lat/lon) wired into the New Trip sheet; `WeatherProvider` (`WeatherKit`) shows live conditions in the trip header; `RecommendationService` gains deterministic weather rules (rain → umbrella/rain shell, cold lows → layers/gloves, heat → sun protection). Unsigned sideload builds lack the WeatherKit entitlement, so weather is designed to fail silently into the offline text engine — never a blocker.
- **Tests:** 5 new deterministic, offline `WeatherRecommendationTests` (rain/cold/heat/fallback/precipitation-window averaging) in `PackWiseTests`. `Trip` gains optional `destinationLatitude`/`destinationLongitude`.
- **CI bug fixed earlier this session chain:** `validate_app()` stdout pollution (diagnostics corrupting the `$APP` path — the build failure after Swift compilation succeeded) and the hardcoded `iPhone 16` test destination (now dynamic simulator discovery).
- Docs: `docs/FULLPACK-CAPABILITY-MATRIX.md`, `docs/APPLE-API-CAPABILITY-BIBLE.md`, `docs/ARCHITECTURE.md`, `docs/BUILD.md`, `docs/CI.md` added; wiki `Features` updated.

**Validation:** web `tsc` 0 · Vite build 0 · `bash -n` 3/3 scripts · `js-yaml` 3/3 workflows · Convex codegen OK · stale `CIOKFVVM`/`isolate/` absent. **Pending:** the next macOS CI run is the acceptance gate for the new Swift files (Xcode compile + archive + IPA verification).

## 1.0.14 — Bulletproof .searchActions shim + streamlined release process (2026-08-08)

**Hardened the iOS-18 .searchActions availability shim further.** The previous fix (1.0.13) put a fully `@available(iOS 18.0, *)` wrapper around `.searchActions`, but a generic-`Content` `ViewModifier` returning `some View` still forces the compiler to consider type witnesses for both branches at the iOS-17 deployment target — a known compile-time resolution hazard for any SwiftUI iOS-version shim. Session 9 hardens the pattern with the canonical workaround: `body` returns `AnyView` and the iOS-18 branch is a separate `@available(iOS 18.0, *) struct SearchActionsWrapper<Content: View>`. This delivers:

- **No path at iOS-17 deployment requires `.searchActions` to resolve.** The compiler unifies `AnyView(...) | AnyView(content)` — both opaque, both available everywhere — instead of `_ConditionalContent<SearchActionsWrapper<Content>, Content>` whose internal conformance must be re-checked.
- **Same user experience on both OS levels.** iOS 18+ gets the explicit "Clear search" accessory toolbar button; iOS 17 falls back to the platform's built-in clear button inside the search field (which already exists there).
- **Audited clean across the iOS source.** Zero fixed-size fonts (Dynamic Type pass is full: every font is a semantic style or `@ScaledMetric`, no `system(size:)` left); zero stray `#available` blocks; zero other iOS-18-only APIs (`scrollPosition(defaultDistance:)`, `defaultScrollAnchor(.top)`, `MeshGradient`, etc.).

**README gains a dedicated Release process section** so the maintainer's day-one workflow is one look-up, not archeology:

- **Triggers → publishes** table: push to `main` → artifact + `dev` prerelease (direct `.ipa`); `v*` tag → versioned GitHub Release; manual *Run workflow* → with `xcode_version`, `skip_tests`, `release_channel` inputs; push to `wiki/` → `wiki.yml` syncs to `Alot1z/packwise/wiki`.
- **One gate: `scripts/verify-ipa.sh`.** Zip integrity → `Payload/PackWise.app` exists → arm64 device Mach-O (`LC_BUILD_VERSION platform 2`, never 7=simulator) → no `*.xctest` and no XCTest/XCUIAutomation/Testing frameworks → main executable is non-empty. If the gate fails, no artifact, no release, no `dev` — even though something may have built.
- **Two deterministic manifest URLs, no GitHub API key: `releases/latest/download/PackWise-releases.json` and `releases/download/dev/PackWise-releases.json`.** Each entry carries `verified_by_build`, `sha256`, `size_bytes`, `changelog_url`, `release_notes_url` — the `verified_by_build: true` field is set by CI only and the site reads it live.
- **Three equal hosts:** GitHub Actions (hosted), Gitea Actions (self-hosted, mirror YAML in `.gitea/workflows/ios.yml`), and `act` locally on macOS-15 (`brew install act && act -W .github/workflows/ios.yml -P macos-15=-self-hosted`). All three share the same `ios/build.sh` cascade and same gating script.
- **Pre-flight 3-check loop** (≤ 15 s) before tagging: `bun tsc -b --noEmit`; `bash -n` on the gate scripts; `npx js-yaml .github/workflows/ios.yml`; then `git tag vX.Y.Z -m "PackWise X.Y.Z" && git push origin vX.Y.Z`.

**Verification and sync:**

- `tsc` exit 0 · `bash -n` 4/4 scripts · `js-yaml` 3/3 workflows · changelog parity **15/15** web ↔ wiki.
- iOS source: 22 Swift files tracked (21 previously + `SearchClearActionsModifier.swift`), all compile-safe on iOS 17.
- `EXECUTION-STATE.md` phase 15 (bulletproof shim + release process), `FILE-AUDIT.md` updated with session 9 (1 new file, 1 fix-hardened, README refreshed).
- **External gate unchanged:** the next macOS CI run still produces the first valid device arm64 IPA. The compile hazard is now structurally impossible to repeat.

## 1.0.13 — R2 CLOSED: the iOS 18 API bug that no run could reach (2026-08-08)

**The infrastructure fix worked — this time the compiler really ran.**

- **R2 infrastructure blocker CLOSED:** live CI run [31256274224](https://github.com/Alot1z/packwise/actions/runs/31256274224) shows the session-6 fix working end-to-end: the **"Install iOS device platform (on demand)"** step succeeded (macOS-15 runner now has the iOS *device* platform), XcodeGen generated the project, and **the Swift compiler actually executed** — the first real compilation in the entire R2 saga. All previous runs died in <1s at destination resolution; this run got past everything.
- **The true remaining bug, exposed by the public annotation channel:** with a real build running, the failure was a **Swift compile error**, not signing and not packaging: `value of type 'some View' has no member 'searchActions'` at `TripListView.swift:74` and `GlobalSearchView.swift:69`, plus a cascade error at `TripListView.swift:86` (`cannot infer contextual base in reference to member 'bottom'`).
- **Root cause:** `.searchActions` is an **iOS 18-only API**, but PackWise's deployment target is **iOS 17**. The modifier was added in an earlier polish pass without an availability guard, so the app could never compile for its own target — the bug was unreachable until the platform fix let CI actually build.
- **Fix:** new availability-safe `searchClearAction(_:clearLabel:)` view modifier in `ios/PackWise/Views/SearchClearActionsModifier.swift` — it applies `.searchActions` only inside `if #available(iOS 18.0, *)` and degrades to the platform's built-in clear button on iOS 17 (same user outcome, zero API risk). Both views updated; grep confirms no unguarded `searchActions` call remains.
- **Verified:** `tsc` exit 0 · `bash -n` 4/4 scripts · `js-yaml` 3/3 workflows (ios.yml, wiki.yml, gitea ios.yml) · grep sweep clean. The next macOS CI run is the closure gate for the *binary* — it should produce the first valid device arm64 IPA since the very first broken `dev` artifact.

## 1.0.12 — Full verification sweep + documentation sync (2026-08-08)

**Session 7 — verify everything, fix documentation, sync all surfaces:**

- Full verification sweep across the entire project: `tsc` exit 0 (TypeScript), `bash -n` 4/4 scripts (verify-ipa, release-manifest, rewrite-history, build.sh), `js-yaml` 3/3 workflows (ios.yml, wiki.yml, gitea ios.yml), `convex dev --once` OK.
- Fixed changelog parity count: the 1.0.11 verification line said "changelog parity 11/11" but there are 12 versions (1.0.0 through 1.0.11); corrected to "12/12" across both the web Changelog page and this wiki page.
- Audited all 7 web pages (Landing, Download, Features, Setup, Docs, Troubleshooting, Changelog), site-shared.tsx (nav, footer, manifest hook), and all 10 wiki pages — every surface is accurate, truthful, and consistent with the implementation.
- Verified the Convex backend (auth email OTP, packing CRUD, http routes) and the PWA manifest — all branded as PackWise, no leftover FreeBuff template references.
- Updated `docs/engineering/EXECUTION-STATE.md` with session 7 results: phase 13 logged, verification sweep recorded, next dependency-ready tasks enumerated.

**Pending:** R2 closure still gated on the next macOS CI run (fix deployed in 1.0.11 — `xcodebuild -downloadPlatform iOS`); the `dev` release still hosts the stale broken IPA until a green run replaces it. All other blockers (R1, R3, R4) remain closed.

## 1.0.11 — R2 closed: missing iOS device platform on runners, not signing (2026-08-08)

**R2 — the real root cause, finally public:**

- The public annotation channel paid off: run [31248752593](https://github.com/Alot1z/packwise/actions/runs/31248752593) surfaced the **actual error** with zero credentials —
  `xcodebuild: error: Unable to find a destination matching the provided destination specifier: { platform:iOS, id:dvtdevice-DVTiPhonePlaceholder-iphoneos:placeholder, name:Any iOS Device, error:iOS 18.0 is not installed. To use with Xcode, first download and install the platform }`.
- It was **never a signing problem**. GitHub macOS-15 runner images trim the iOS **device** platform to save disk (actions/runner-images #12758 / #12862 / #13570); `xcodebuild -destination "generic/platform=iOS"` then dies in under a second — which is exactly why every run failed at the "Build unsigned IPA" step ~7–8s in, and why the simulator *tests* step (which doesn't need the device platform) passed. All four signing-arg fixes in 1.0.9/1.0.10 were hygiene, not the blocker.
- **Fix:** the workflow now runs `xcodebuild -downloadPlatform iOS` (official remedy; no-op when already installed, sudo fallback for root-owned platform dirs) before the build, and picks the **newest** installed Xcode instead of the first alphabetically. `ios/build.sh` gained a self-healing `ensure_device_platform()` guard so standalone local macOS builds heal too. Mirrored in the Gitea workflow.
- **Verification:** `tsc` exit 0 · `bash -n` 4/4 scripts · `js-yaml` 3/3 workflows · changelog parity 12/12 surfaces · live CI evidence chain re-pulled (runs 31248752593, 31248315617) · local fixes diff vs GitHub `main` confirmed as the not-yet-shipped delta.

**Pending:** the fix ships on the next auto-sync push; the following macOS CI run is the R2 closure gate (annotations will show the exact state either way). The `dev` release still hosts the stale broken IPA until a green run replaces it via the publish gate.

## 1.0.10 — R2 signing-arg fix + public failure annotations + web brand polish (2026-08-08)

**R2 ("Bad file descriptor" / device build) — third root cause fixed:**

- The 1.0.9 signing overrides **shipped** (verified: GitHub `main` == local `ios/build.sh`), yet push runs ([31246529945](https://github.com/Alot1z/packwise/actions/runs/31246529945), [31248315617](https://github.com/Alot1z/packwise/actions/runs/31248315617)) still failed at the "Build unsigned IPA" step **~7–8 seconds** after tests — an immediate `xcodebuild` configuration error, not a compile error.
- Root causes found in sequence: (a) `NO_SIGN_STR` word-split passed **literal quote characters** to `xcodebuild` (`CODE_SIGN_IDENTITY=""` — quote removal does not happen on variable expansion); (b) an explicit `DEVELOPMENT_TEAM=` — even empty — makes Xcode 15/16 try to resolve a team; (c) **`CODE_SIGN_STYLE=Manual` itself**: with Manual style Xcode demands a resolvable team/identity even when signing is disabled, whereas the CI *tests* step (which passes on the same runner) keeps the project's `Automatic` style and sets only `CODE_SIGN_IDENTITY=""`.
- Fix: `ios/build.sh` signing args are now a clean bash array matching the proven-passing tests step exactly — `NO_SIGN=(CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO CODE_SIGN_IDENTITY=)` — with no `CODE_SIGN_STYLE`/`DEVELOPMENT_TEAM` overrides. A fourth minimal strategy (D, mirrors the passing tests invocation) was added to the self-healing cascade. Verified: each argument expands as a clean token (no quotes), `bash -n` clean.
- **Public failure channel:** GitHub Actions *logs* and *artifacts* require sign-in (403/401), but check-run **annotations are public**. `build.sh` now emits `::error::` workflow-command lines with the real error text on every failure, so the next run's annotations endpoint (`check-runs/{id}/annotations`, no auth) exposes the exact error — no more blind diagnosis.
- Evidence recorded: the `dev` release still hosts the old broken IPA (5,004,581 bytes — the exact verified-broken artifact); the publish gate correctly prevented any replacement so far.

**Web & app polish:**

- `public/manifest.webmanifest` rebranded — was still the platform template ("freebuff.com application", icon `/logo.png` which does not exist); now PackWise-branded with the real `/logo.svg` icon, correct theme colors, travel categories, and scope.
- `ContentView` onboarding transition is now reduced-motion gated (`.animation(reduceMotion ? nil : .easeInOut(...))` via `@Environment(\.accessibilityReduceMotion)`) — users with Reduce Motion on get an instant swap.
- Auth OTP email `appName` fallback now "PackWise" instead of "a freebuff.com application".

**Verification:** `tsc` exit 0 · `bash -n` 4/4 scripts · `js-yaml` 3/3 workflows · changelog parity 11/11 surfaces (web ↔ wiki) · live CI evidence pulled from the GitHub API (runs/jobs/check-runs).

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
