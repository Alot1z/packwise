# PackWise — File Audit Manifest

> Every relevant file is tracked here with an honest audit status.
> **Status legend:** ✅ = fully read this session · 🕒 = pending full re-read
> (edited/read in earlier sessions but not re-verified this session) ·
> ⚙️ = inspected via grep/search only.
> "Lines" is approximate. **Status reflects evidence, not memory.**

## Release-critical (audited this session)

| Path | Purpose | Lines | Status | Action | Issues | Validation |
|---|---|---|---|---|---|---|
| `.github/workflows/ios.yml` | GH Actions: build → test → IPA → verify → release | 238 | ✅ | **FIXED** | R1: python block at column 0 inside `run: \|` broke YAML (line 148); manifest step crashed on `dev: null` (both fixed) | js-yaml parse OK · python step smoke OK (with `dev: null`) |
| `.gitea/workflows/ios.yml` | Gitea Actions mirror | 172 | ✅ | KEEP | none found | js-yaml parse OK |
| `ios/build.sh` | 3-strategy IPA build + strict publish gate | ~150 | ✅ | KEEP | none found; packaging intentionally untouched pending R2 evidence | `bash -n` OK |
| `scripts/verify-ipa.sh` | One-command sideload verifier (also CI gate) | ~140 | ✅ | **HARDENED** | could not classify symlink / empty / non-Mach-O executables; Mach-O probe had inverted endianness (both fixed) | **4/4 fixtures PASS** · `bash -n` OK |
| `scripts/release-manifest.sh` | Emits `PackWise-releases.json` (schema v1) | ~150 | ✅ | KEEP | none found | smoke run OK |
| `ios/project.yml` | XcodeGen config (device-first, tests isolated from archive) | 90 | ✅ | KEEP | none found | reviewed |
| `wiki/Changelog.md` | Canonical changelog | ~100 | ✅ | **EDITED** | 1.0.7 title was prompt-flavored; retitled; 1.0.8 added | reviewed |
| `README.md` | Project README | 430 | ✅ | REVIEW | structurally strong; §21 wants screenshots/contributing additions | read |
| `src/pages/Landing.tsx` | Landing page | 780 | ✅ | **EDITED** | fictional "Kyoto · 62% packed" shown as real; screenshot grid under-labeled | `tsc` 0 |
| `src/pages/Changelog.tsx` | Site changelog page | 130 | ✅ | **EDITED** | missing 1.0.7 entry | `tsc` 0 |

## Pending full re-read (rows from earlier sessions — evidence not yet re-verified)

| Path | Purpose | Status | Action |
|---|---|---|---|
| `src/pages/Download.tsx` | Download / verify page (live manifest driven) | 🕒 | AUDIT (re-verify no fabricated status) |
| `src/pages/Setup.tsx` | Setup wizard | 🕒 | AUDIT |
| `src/pages/Docs.tsx` | Docs index | 🕒 | AUDIT |
| `src/pages/Features.tsx` | Features page | 🕒 | AUDIT |
| `src/pages/Troubleshooting.tsx` | Troubleshooting page | 🕒 | AUDIT |
| `src/pages/Dashboard.tsx` | Site dashboard (docs status) | 🕒 | AUDIT |
| `src/pages/Auth.tsx` · `NotFound.tsx` | Auth / 404 | 🕒 | AUDIT |
| `src/components/site-shared.tsx` | Nav/footer/shared | 🕒 | AUDIT |
| `src/index.css` | Global styles (tokens, reduced-motion, print) | 🕒 | AUDIT |
| `index.html` | SEO/OG/JSON-LD shell | 🕒 | AUDIT |
| `ios/PackWise/App/PackWiseApp.swift` · `ContentView.swift` | App entry + tabs | 🕒 | AUDIT |
| `ios/PackWise/Models/Models.swift` | SwiftData models | 🕒 | AUDIT |
| `ios/PackWise/Services/VisionService.swift` · `RecommendationService.swift` · `NotificationService.swift` | On-device services | 🕒 | AUDIT |
| `ios/PackWise/Views/*.swift` (12 files) | All SwiftUI views | 🕒 | AUDIT |
| `ios/PackWise/Info.plist` | App metadata / permissions strings | 🕒 | AUDIT |
| `ios/PackWise/Resources/Assets.xcassets` | Accent + programmatic app icon | 🕒 | AUDIT |
| `ios/PackWiseTests/` · `PackWiseUITests/` | Unit + UI tests | 🕒 | AUDIT |
| `ios/README.md` | iOS build doc | 🕒 | AUDIT |
| `wiki/*.md` (Home, Architecture, Build-and-Release, Data-Models, Features, Installation, Troubleshooting, Vision-and-Privacy) | Wiki source | 🕒 | AUDIT |
| `scripts/generate-appicon.py` · `rewrite-history.sh` | Tooling | 🕒 | AUDIT |
| `.github/workflows/wiki.yml` | Wiki sync | 🕒 | AUDIT |
| `package.json` · `vite.config.ts` · `components.json` · `convex.json` · `tsconfig*` | Web config | 🕒 | AUDIT |
| `.actrc` · `.gitignore` · `LICENSE` | Meta | 🕒 | AUDIT |

## Investigate

| Path | Note | Action |
|---|---|---|
| `isolate/` | Stray directory containing a FreeBuff `manifest.webmanifest` + `logo.svg` — looks like a deployment copy, not project source | INVESTIGATE — candidate for DELETE after confirmation |

## Rules

- A row only becomes ✅ when the file has been re-read in a session (evidence, not memory).
- Every future session starts by: read this file → pick the first 🕒 row relevant to the
  current task → read it → update its status → validate → update EXECUTION-STATE.md.
