# PackWise — File Audit Manifest

> Every relevant file is tracked here with an honest audit status.
> **Status legend:** ✅ = fully read this session · 🕒 = pending full re-read ·
> ⚙️ = inspected via grep/search only. **Status reflects evidence, not memory.**

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

## iOS application — full line-by-line audit (this session, 19 files, 2,252 lines)

| Path | Lines | Status | Action | Issues | Validation |
|---|---|---|---|---|---|
| `ios/PackWise/App/PackWiseApp.swift` | 12 | ✅ | KEEP | none | read |
| `ios/PackWise/App/ContentView.swift` | 89 | ✅ | KEEP | minor: `.animation` not reduced-motion gated (trivial fade) | read |
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

## Pending full re-read

| Path | Status | Action |
|---|---|---|
| `src/pages/Setup.tsx` · `Docs.tsx` · `Features.tsx` · `Troubleshooting.tsx` · `Dashboard.tsx` · `Auth.tsx` · `NotFound.tsx` | 🕒 | AUDIT |
| `src/index.css` · `index.html` | 🕒 | AUDIT |
| `ios/README.md` · `wiki/*.md` (9 pages) | 🕒 | AUDIT (docs accuracy re-check vs this session's changes) |
| `scripts/generate-appicon.py` · `rewrite-history.sh` | 🕒 | AUDIT |
| `package.json` · `vite.config.ts` · `components.json` · `convex.json` · `tsconfig*` | 🕒 | AUDIT |
| `.actrc` · `.gitignore` · `LICENSE` | 🕒 | AUDIT |

## Investigate

| Path | Note | Action |
|---|---|---|
| `isolate/` | Stray FreeBuff deployment copy (`manifest.webmanifest` + `logo.svg`) | INVESTIGATE — candidate for DELETE after confirmation |

## Rules

- A row only becomes ✅ when the file has been re-read in a session (evidence, not memory).
- Every future session starts by: read this file → pick the first 🕒 row relevant to the current task → read it → update its status → validate → update EXECUTION-STATE.md.
