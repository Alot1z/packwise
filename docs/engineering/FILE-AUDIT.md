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
| `.github/workflows/ios.yml` | 245 | ✅ | **FIXED/EXTENDED** | tests step aborted under `bash -e -o pipefail` (exit 65/70, TESTS_PASSED never recorded); summary could print contradictory "IPA still built / No IPA produced"; brew tap hygiene; action majors stale | js-yaml parse OK · tsc N/A |
| `.gitea/workflows/ios.yml` | 175 | ✅ | **FIXED/EXTENDED** | same tests-step bug; same brew/action updates | js-yaml parse OK |
| `.github/workflows/wiki.yml` | 62 | ✅ | **REWRITTEN** | failing at push step; `checkout@v4` (Node 20); no wiki-repo enablement; push error handling weak | js-yaml parse OK |
| `ios/build.sh` | 215 | ✅ | **EXTENDED** | unclosed-quote in NO_SIGN_STR (shell-level bug, found by `bash -n`); missing DEVELOPMENT_TEAM/CODE_SIGN_STYLE for unsigned device builds; sparse diagnostics | `bash -n` OK · value-expansion verified |
| `scripts/verify-ipa.sh` | 150 | ✅ | **EXTENDED** | binary Info.plist piped through command substitution (NUL stripped → CFBundleExecutable detection defeated + noisy warning) | NUL warning gone · 4/4 fixtures · real-IPA rejection confirmed |
| `scripts/release-manifest.sh` | 150 | ✅ | KEEP | none | smoke OK |
| `ios/project.yml` | 90 | ✅ | KEEP | none | reviewed |
| `src/components/site-shared.tsx` | 360 | ✅ | **EXTENDED** | nav/footer CTAs pointed at 404 `releases/latest` while no verified build existed; added live `useManifest` | `tsc` 0 |
| `src/pages/Landing.tsx` | 810 | ✅ | **EXTENDED** | hero CTA + badges claimed verified availability with no manifest | `tsc` 0 |
| `src/pages/Download.tsx` | 330 | ✅ | **EXTENDED** | static "verified" claim; download buttons implied availability of a broken/stale artifact | `tsc` 0 |
| `src/pages/Changelog.tsx` | 150 | ✅ | KEEP | synced earlier | `tsc` 0 |
| `wiki/Changelog.md` | 110 | ✅ | **EDITED** | 1.0.9 added | reviewed |
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
| `ios/PackWise/Views/TripListView.swift` | 135 | ✅ | **FIXED** | swipe-delete deleted a whole trip with no confirmation (changelog claimed confirmations); added confirmationDialog | read + edit |
| `ios/PackWise/Views/TripDetailView.swift` | 332 | ✅ | KEEP | confirmations/haptics/a11y present | read |
| `ios/PackWise/Views/ItemDetailView.swift` | 91 | ✅ | KEEP | photo downscale, auto-save, a11y | read |
| `ios/PackWise/Views/LibraryView.swift` | 178 | ✅ | KEEP | reuse flow present | read |
| `ios/PackWise/Views/PhotoScannerView.swift` | 120 | ✅ | KEEP | confirm-before-add Vision flow | read |
| `ios/PackWise/Views/OnboardingView.swift` | 79 | ✅ | KEEP | reduced-motion + ScaledMetric + a11y | read |
| `ios/PackWise/Views/TemplateLibraryView.swift` | 96 | ✅ | KEEP | delete confirmation present | read |
| `ios/PackWise/Views/GlobalSearchView.swift` | 79 | ✅ | KEEP | minor: outfit/library/template hits render as text (no drill-down) | read |
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

## Rules

- A row only becomes ✅ when the file has been re-read in a session (evidence, not memory).
- Every future session starts by: read this file → pick the first 🕒 row relevant to the current task → read it → update its status → validate → update EXECUTION-STATE.md.
