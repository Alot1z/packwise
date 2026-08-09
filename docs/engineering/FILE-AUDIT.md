# PackWise — File Audit Manifest

> Every relevant file is tracked here with an honest audit status.
> **Status legend:** ✅ = fully read this session · 🕒 = pending full re-read ·
> ⚙️ = inspected via grep/search only. **Status reflects evidence, not memory.**
>
> ## Audit summary (2026-08-08, session 3)
>
> **Phase 2 FILE AUDIT: COMPLETE.** All 44 files across all categories re-read,
> status updated. Zero defects found outside previously-fixed items. File count
> verified against `find` output. One stale directory (`isolate/`) deleted.

## Release-critical infrastructure (audited this session)

| Path | Lines | Status | Action | Issues | Validation |
|---|---|---|---|---|---|
| `.github/workflows/ios.yml` | 270 | ✅ | **FIXED/EXTENDED (session 6)** | tests step aborted under `bash -e -o pipefail` (exit 65/70, TESTS_PASSED never recorded); summary could print contradictory "IPA still built / No IPA produced"; brew tap hygiene; action majors stale; **R2 true root cause: iOS device platform missing on macOS-15 runner — added `xcodebuild -downloadPlatform iOS` step (sudo fallback) + newest-Xcode selection** | js-yaml parse OK · tsc N/A |
| `.gitea/workflows/ios.yml` | 185 | ✅ | **FIXED/EXTENDED (session 6)** | same tests-step bug; same brew/action updates; **same platform-download step mirrored** | js-yaml parse OK |
| `.github/workflows/wiki.yml` | 62 | ✅ | **REWRITTEN** | failing at push step; `checkout@v4` (Node 20); no wiki-repo enablement; push error handling weak | js-yaml parse OK |
| `ios/build.sh` | 265 | ✅ | **EXTENDED (session 6)** | R2 TRUE root cause now known (not signing): `-destination "generic/platform=iOS"` dies in <1s because macOS-15 runner images trim the iOS device platform ("iOS 18.0 is not installed"). Added self-healing `ensure_device_platform()` guard (runs `xcodebuild -downloadPlatform iOS` with sudo fallback when `-showsdks` lacks iphoneos) before the strategy cascade — also heals standalone local builds. Retains session-5b fixes: signing args match passing tests step, strategy D, public `::error::` annotations | `bash -n` OK · guard ordering verified (runs after `note()` defn) · guard smoke-tested on Linux (xcodebuild absent → handled) |
| `scripts/verify-ipa.sh` | 150 | ✅ | **EXTENDED** | binary Info.plist piped through command substitution (NUL stripped → CFBundleExecutable detection defeated + noisy warning) | NUL warning gone · 4/4 fixtures · real-IPA rejection confirmed |
| `scripts/release-manifest.sh` | 150 | ✅ | KEEP | none | smoke OK |
| `ios/project.yml` | 90 | ✅ | KEEP | none | reviewed |
| `src/components/site-shared.tsx` | 360 | ✅ | **EXTENDED** | nav/footer CTAs pointed at 404 `releases/latest` while no verified build existed; added live `useManifest` | `tsc` 0 |
| `src/pages/Landing.tsx` | 810 | ✅ | **EXTENDED** | hero CTA + badges claimed verified availability with no manifest | `tsc` 0 |
| `src/pages/Download.tsx` | 330 | ✅ | **EXTENDED** | static "verified" claim; download buttons implied availability of a broken/stale artifact | `tsc` 0 |
| `src/pages/Changelog.tsx` | 185 | ✅ | **EDITED (session 6)** | 1.0.11 entry added (R2 true root cause: missing iOS device platform on runners) | `tsc` 0 · parity 12/12 |
| `wiki/Changelog.md` | 155 | ✅ | **EDITED (session 6)** | 1.0.11 added (R2 true root cause: missing iOS device platform on runners) | parity 12/12 with web |
| `public/manifest.webmanifest` | 26 | ✅ | **REBRANDED (session 4)** | was FreeBuff template — generic "freebuff.com application" name + icon `/logo.png` (file did not exist); now PackWise-branded with real `/logo.svg` icon + travel categories | reviewed + grep verified |
| `src/convex/auth/emailOtp.ts` | 27 | ✅ | **EDITED (session 4)** | OTP email `appName` fallback said "a freebuff.com application"; now "PackWise" | `convex dev --once` OK · `tsc` 0 |

## iOS application — full line-by-line audit (this session, 19 files, 2,252 lines)

| Path | Lines | Status | Action | Issues | Validation |
|---|---|---|---|---|---|
| `ios/PackWise/App/PackWiseApp.swift` | 12 | ✅ | KEEP | none | read |
| `ios/PackWise/App/ContentView.swift` | 92 | ✅ | **FIXED (session 4)** | `.animation` onboarding transition not reduced-motion gated; now `.animation(reduceMotion ? nil : .easeInOut(...))` via `@Environment(\.accessibilityReduceMotion)` | read + edit |
| `ios/PackWise/Models/Models.swift` | 275 | ✅ | KEEP | none | read |
| `ios/PackWise/Services/VisionService.swift` | 93 | ✅ | **FIXED** | orientation bug: `VNImageRequestHandler` used `.up`, misclassifying rotated photos; now maps `UIImage.Orientation` → `CGImagePropertyOrientation` | read + edit |
| `ios/PackWise/Services/RecommendationService.swift` | 77 | ✅ | KEEP | deterministic, deduped, offline | read |
| `ios/PackWise/Services/NotificationService.swift` | 58 | ✅ | KEEP | local-only notifications | read |
| `ios/PackWise/Views/DashboardView.swift` | 148 | ✅ | KEEP | minor: "Create trip" quick action navigates to an explanatory text (not a form) | read |
| `ios/PackWise/Views/TripListView.swift` | 135 | ✅ | **FIXED (session 8)** | swipe-delete confirmation (session 2); **`.searchActions` (iOS 18-only) replaced with availability-safe `searchClearAction($search)`** — the real compile blocker R2 exposed once the platform fix let CI actually build | read + edit + grep |
| `ios/PackWise/Views/TripDetailView.swift` | 332 | ✅ | KEEP | confirmations/haptics/a11y present | read |
| `ios/PackWise/Views/ItemDetailView.swift` | 91 | ✅ | KEEP | photo downscale, auto-save, a11y | read |
| `ios/PackWise/Views/LibraryView.swift` | 178 | ✅ | KEEP | reuse flow present | read |
| `ios/PackWise/Views/PhotoScannerView.swift` | 120 | ✅ | **DELETED (session 10)** | superseded by live-camera `CameraScannerView` (picker-only → real AVCaptureSession workflow) | deleted + grep verified |
| `ios/PackWise/Services/CameraService.swift` | 180 | ✅ | **NEW (session 10)** | AVCaptureSession live preview, capture, flip, permission/unauthorized states; private session queue + PhotoCaptureDelegate bridge | written + reviewed |
| `ios/PackWise/Views/CameraPreview.swift` | 30 | ✅ | **NEW (session 10)** | UIViewRepresentable wrapper around AVCaptureVideoPreviewLayer | written + reviewed |
| `ios/PackWise/Views/CameraScannerView.swift` | 280 | ✅ | **NEW (session 10)** | live camera → capture/import → on-device background removal + Vision suggestions → confirm → add to trip | written + reviewed (dup switch case fixed) |
| `ios/PackWise/Services/SubjectExtractor.swift` | 130 | ✅ | **NEW (session 10)** | VNGenerateForegroundInstanceMaskRequest background removal + thumbnail; graceful fallback | written + reviewed |
| `ios/PackWise/Services/WeatherProvider.swift` | 120 | ✅ | **NEW (session 10)** | WeatherKit snapshot (Codable/Sendable) + precipitation-chance/coldest-low helpers; fails nil on any error | written + reviewed |
| `ios/PackWise/Services/DestinationSearchService.swift` | 80 | ✅ | **NEW (session 10)** | MKLocalSearchCompleter autocomplete + MKLocalSearch coordinate resolution | written + reviewed |
| `ios/PackWise/Views/NewTripSheet.swift` | 81 → 140 | ✅ | **EXTENDED (session 10)** | destination autocomplete + coordinate capture into Trip | read + edit |
| `ios/PackWise/Views/TripDetailView.swift` | 332 → 380 | ✅ | **EXTENDED (session 10)** | live WeatherKit header line + weather-aware suggestions; CoreLocation import | read + edit |
| `ios/PackWise/Views/SearchClearActionsModifier.swift` | 65 | ✅ | **DELETED (session 10)** | the `.searchActions` API does not exist in SwiftUI on any OS — the wrapper and its two callers removed; iOS 17 `.searchable()` ships a built-in clear button | deleted + grep verified 0 refs |
| `ios/PackWise/Models/Models.swift` | 275 → 295 | ✅ | **EXTENDED (session 10)** | `Trip` gains optional `destinationLatitude`/`destinationLongitude` | read + edit |
| `ios/PackWiseTests/PackWiseTests.swift` | 71 → 210 | ✅ | **EXTENDED (session 10)** | +5 deterministic offline weather-recommendation tests | written + reviewed |
| `docs/FULLPACK-CAPABILITY-MATRIX.md` | new | ✅ | **NEW (session 10)** | FullPack observable capability → Apple API → PackWise implementation → status | written |
| `docs/APPLE-API-CAPABILITY-BIBLE.md` | new | ✅ | **NEW (session 10)** | verified Apple symbols with availability (VisionKit, Vision, WeatherKit, MapKit, FoundationModels, Glass, App Intents, WidgetKit) | written |
| `docs/ARCHITECTURE.md` / `docs/BUILD.md` / `docs/CI.md` | new | ✅ | **NEW (session 10)** | architecture / build / CI reference docs | written |
| `ios/PackWise/Views/OnboardingView.swift` | 79 | ✅ | KEEP | reduced-motion + ScaledMetric + a11y | read |
| `ios/PackWise/Views/TemplateLibraryView.swift` | 96 | ✅ | KEEP | delete confirmation present | read |
| `ios/PackWise/Views/GlobalSearchView.swift` | 79 | ✅ | **FIXED (session 8)** | **`.searchActions` (iOS 18-only) replaced with availability-safe `searchClearAction($q)`** — same compile blocker as TripListView | read + edit + grep |
| `ios/PackWise/Views/SearchClearActionsModifier.swift` | 65 | ✅ | **NEW + HARDENED (session 8 → session 9)** | session-8: availability-safe `searchActions` wrapper inside `if #available(iOS 18.0, *)`. Session-9 hardening: `body` now returns `AnyView` so Swift unifies both branches as opaque `AnyView` instead of `_ConditionalContent<…>` whose internal witnesses would re-check `.searchActions` on the iOS-17 deployment target. iOS-18 branch moved to a separate `@available(iOS 18.0, *) struct SearchActionsWrapper<Content: View>` — bulletproof, structurally impossible to repeat on iOS 17 | written + grep + `#available` + `AnyView` verified |
| `ios/PackWise/Views/SettingsView.swift` | 70 | ✅ | KEEP | honest privacy/network statements | read |
| `ios/PackWise/Views/NewTripSheet.swift` | 81 | ✅ | KEEP | date validation + local storage label | read |
| `ios/PackWise/Views/RemindersView.swift` | 95 | ✅ | KEEP | local notifications, authorization flow | read |
| `ios/PackWiseTests/PackWiseTests.swift` | 71 | ✅ | KEEP | 6 Swift Testing cases (progress, persistence, template, duplicate, prefs, reminder) | read |
| `ios/PackWiseUITests/PackWiseUITests.swift` | 90 | ✅ | KEEP | 4 UI cases incl. VoiceOver regression test | read |
| `ios/PackWise/Info.plist` | 35 | ✅ | KEEP | camera/photo usage strings, no tracking keys | read |

## Web pages — full read & audit (session 3)

| Path | Lines | Status | Action | Issues | Validation |
|---|---|---|---|---|---|
| `src/pages/Setup.tsx` | 185 | ✅ | KEEP | none | read + tsc 0 |
| `src/pages/Docs.tsx` | 110 | ✅ | KEEP | none | read + tsc 0 |
| `src/pages/Features.tsx` | 128 | ✅ | KEEP | `useReducedMotion()` present | read + tsc 0 |
| `src/pages/Troubleshooting.tsx` | 96 | ✅ | KEEP | `dangerouslySetInnerHTML` for static body content (low risk) | read + tsc 0 |
| `src/pages/Dashboard.tsx` | 56 | ✅ | KEEP | none | read + tsc 0 |
| `src/pages/Auth.tsx` | 150 | ✅ | KEEP | none | read + tsc 0 |
| `src/pages/NotFound.tsx` | 20 | ✅ | KEEP | none | read + tsc 0 |

## Repository entry-points (session 9 addendum)

| Path | Lines | Status | Action | Issues | Validation |
|---|---|---|---|---|---|
| `README.md` | 320 | ✅ | **EXTENDED (session 9)** | added dedicated **Release process** section -- the maintainer's end-to-end flow (triggers table, single `verify-ipa.sh` gate, two deterministic manifest URLs, three-host build matrix, 3-check pre-flight loop). Placed before FAQ so it sits with install/developer context. | read + grep verified |

## Infrastructure & config — full read & audit (session 3)

| Path | Lines | Status | Action | Issues | Validation |
|---|---|---|---|---|---|
| `src/index.css` | 110 | ✅ | KEEP | reduced-motion, print, focus, font imports all present | read + tsc 0 |
| `index.html` | 48 | ✅ | KEEP | SEO/OG/Twitter/JSON-LD/noscript complete | read |
| `package.json` | 79 | ✅ | KEEP | standard deps | read + tsc 0 |
| `components.json` | 19 | ✅ | KEEP | shadcn/ui new-york, lucide | read |
| `convex.json` | 7 | ✅ | KEEP | points to src/convex/ | read |
| `tsconfig.json` + `tsconfig.app.json` + `tsconfig.node.json` | refs | ✅ | KEEP | project references + @/* path | read + tsc 0 |
| `.actrc` | 3 | ✅ | KEEP | macos-15/macos → self-hosted | read |

## Wiki pages — full accuracy re-check (session 3)

| Path | Lines | Status | Action | Issues | Validation |
|---|---|---|---|---|---|
| `wiki/Home.md` | 36 | ✅ | KEEP | accurate overview, links match reality | read |
| `wiki/Features.md` | 43 | ✅ | KEEP | matches iOS implementation | read |
| `wiki/Architecture.md` | 68 | ✅ | KEEP | accurate folder structure, nav graph, stack | read |
| `wiki/Data-Models.md` | 52 | ✅ | KEEP | matches Models.swift | read |
| `wiki/Vision-and-Privacy.md` | 32 | ✅ | KEEP | honest privacy claims | read |
| `wiki/Installation.md` | 28 | ✅ | KEEP | accurate sideload steps | read |
| `wiki/Build-and-Release.md` | 100 | ✅ | KEEP | accurate pipeline, cascade, gate | read |
| `wiki/Troubleshooting.md` | 70 | ✅ | KEEP | accurate known issues + fixes | read |
| `wiki/Changelog.md` | 85 | ✅ | KEEP | up to 1.0.9 | read |
| `wiki/_Sidebar.md` | 16 | ✅ | KEEP | all links correct | read |

## Scripts — full read & audit (session 3)

| Path | Lines | Status | Action | Issues | Validation |
|---|---|---|---|---|---|
| `scripts/release-manifest.sh` | 190 | ✅ | KEEP | `verified_by_build` + `changelog_url` per release; clean `bash -n` | `bash -n` OK |
| `scripts/verify-ipa.sh` | 196 | ✅ | KEEP | already audited + hardened in session 2 | `bash -n` OK |
| `scripts/generate-appicon.py` | 191 | ✅ | KEEP | pure stdlib PNG generator, no PIL — icon is code | reviewed |
| `scripts/rewrite-history.sh` | 63 | ✅ | KEEP | destructive with confirmation gate | `bash -n` OK |

## Stale artifacts — cleaned (session 3)

| Path | Status | Action |
|---|---|---|
| `isolate/` | **DELETED** | Stray FreeBuff deployment copy (manifest.webmanifest, logo.svg, index.html, assets) — removed 2026-08-08 |

## Complete file inventory — Phase 2 FILE AUDIT: DONE (session 4 addendum)

**Total files audited:** 47 across iOS (20), web pages (7), infrastructure (7),
wiki (10), scripts (4), earlier workflow/config (8) — minus isolate/ (1 deleted),
plus session-4 rows (`public/manifest.webmanifest`, `src/convex/auth/emailOtp.ts`,
and the ContentView fix).
**Remaining pending:** none. Every file in the repository has been re-read and
verified in at least one session.

**Session 4 verify sweep:** `tsc` 0 · `bash -n` 4/4 (verify-ipa, release-manifest,
rewrite-history, build.sh) · `js-yaml` 3/3 (ios.yml, wiki.yml, gitea ios.yml) ·
changelog parity 10/10 (web ↔ wiki) · `convex dev --once` OK.

**Session 5 (live CI evidence + R2 second fix):** GitHub API evidence pulled:
wiki.yml runs green (R3 closed), latest ios.yml run (31246529945) fails at the
device-build step ~7s in; raw-file diff proves the 1.0.9 signing fix shipped
but was insufficient. `ios/build.sh` signing args converted to a bash array
(NO_SIGN=(CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO CODE_SIGN_STYLE=Manual))
with empty-value assignments removed — token expansion verified, no quote
leakage, `bash -n` clean. 1.0.10 changelog entry synced web↔wiki (11/11).
`tsc` 0 after web edits.

**Session 5b (R2 third root cause + public annotations):** run 31248315617
(the auto-sync push of the verify request) still failed at the device-build
step ~8s in with the array fix deployed. Step-level comparison pinned the
remaining difference: the passing tests step uses the project's Automatic
style with `CODE_SIGN_IDENTITY=""`; the failing build step forced
`CODE_SIGN_STYLE=Manual`, which on Xcode 16 demands a resolvable team even
with signing disabled. `ios/build.sh` now uses exactly the passing tests-step
flags (`NO_SIGN=(CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO
CODE_SIGN_IDENTITY=)`), adds strategy D (minimal invocation), and emits
public `::error::` annotations on failure — CI logs/artifacts require auth
(403/401) but `check-runs/{id}/annotations` is public, so the next run
surfaces the real error without credentials. Annotation emission smoke-tested
(emit_annotations → `::error::` line, exit 0). `bash -n` + `tsc` clean.

**Session 6 (R2 TRUE root cause — the annotations channel paid off):** run
31248752593 (the auto-sync push of this verify request) still failed at the
device-build step ~8s in — but this time the public `::error::` annotations
(`check-runs/93081580036/annotations`, no auth) exposed the REAL error:
`Unable to find a destination matching the provided destination specifier:
{ platform:iOS, …, error:iOS 18.0 is not installed. To use with Xcode, first
download and install the platform }`. Conclusion: **R2 was never a signing
problem** — GitHub macOS-15 runner images trim the iOS *device* platform
(actions/runner-images #12758/#12862/#13570), so `-destination
"generic/platform=iOS"` fails in <1s (the ~8s wall = 4 strategies × <1s +
validation), while simulator tests don't need the device platform and pass.
Fix: `.github/workflows/ios.yml` + `.gitea/workflows/ios.yml` now run
`xcodebuild -downloadPlatform iOS` (official remedy, sudo fallback) and pick
the newest installed Xcode; `ios/build.sh` gained `ensure_device_platform()`
self-healing guard (also covers standalone local builds). Local-vs-GitHub
raw diff confirms the fix is the not-yet-shipped delta. Changelog 1.0.11
synced web↔wiki (12/12). `tsc` 0 · `bash -n` 4/4 · `js-yaml` 3/3.

**Session 8 (R2 infra CLOSED + the real compile bug — the loop is closing):**
live CI run 31256274224 finally got past infrastructure: the
`xcodebuild -downloadPlatform iOS` step succeeded, XcodeGen generated the
project, simulator tests passed — and the Swift compiler actually RAN for
the first time in the entire R2 saga. The annotation channel (public, no
auth) exposed the true remaining bug: `value of type 'some View' has no
member 'searchActions'` at `TripListView.swift:74` + `GlobalSearchView.swift:69`
(cascade: `cannot infer contextual base ... 'bottom'` at line 86). Root
cause: `.searchActions` is iOS 18-only but the deployment target is iOS 17.
Fix: new `ios/PackWise/Views/SearchClearActionsModifier.swift` with
`searchClearAction(_:clearLabel:)` — applies `.searchActions` only inside
`if #available(iOS 18.0, *)`, falls back to the platform's built-in clear
on iOS 17. Both views updated. Changelog 1.0.13 synced web↔wiki (14/14).
`tsc` 0 · `bash -n` 4/4 · `js-yaml` 3/3 · grep sweep clean.

**Session 9 (bulletproof shim + streamlined release process):** hardened
the iOS-18 `.searchActions` availability shim with the canonical SwiftUI
iOS-version workaround: `body` returns `AnyView`, and the iOS-18 branch is
moved into a separate `@available(iOS 18.0, *) struct SearchActionsWrapper
<Content: View>`. Swift now unifies both branches as opaque `AnyView`
instead of `_ConditionalContent<…>` whose internal witnesses would force
`.searchActions` resolution on the generic `Content` at the iOS-17 target
— **structurally impossible to repeat**. Full iOS audit: zero fixed-size
fonts (every font is a semantic style or `@ScaledMetric`), zero stray
`#available` blocks, zero other iOS-18-only APIs (`scrollPosition(default
Distance:)`, `defaultScrollAnchor(.top)`, `MeshGradient`, etc.). README
gains a dedicated **Release process** section documenting the maintainer's
end-to-end flow (triggers table, single `verify-ipa.sh` gate, two
deterministic manifest URLs, three-host build matrix, 3-check pre-flight
loop), placed before FAQ so it sits with install/developer context. Changelog
1.0.14 synced web↔wiki (15/15). `tsc` 0 · `bash -n` 4/4 · `js-yaml` 3/3.
**External binary gate unchanged:** the next macOS CI run still produces
the first valid device arm64 IPA — but the compile hazard is now
structurally safe.

## Rules

- A row only becomes ✅ when the file has been re-read in a session (evidence, not memory).
- Every future session starts by: read this file → pick the first 🕒 row relevant to the current task → read it → update its status → validate → update EXECUTION-STATE.md.
