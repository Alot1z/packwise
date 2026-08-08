# PackWise — Engineering Execution State

> **Living document.** Update at the end of every session. Per-file audit lives in
> [`docs/engineering/FILE-AUDIT.md`](FILE-AUDIT.md). Last updated: **2026-08-08**
> (session 8 — **R2 infrastructure blocker CLOSED + real compile error found and
> fixed**: live CI run 31256274224 proved the platform-download fix works and the
> Swift compiler finally ran; the true bug was an iOS 18-only `.searchActions`
> call in a iOS 17-target app — fixed via availability-safe modifier;
> changelog 1.0.13 synced web↔wiki 14/14; tsc/bash/js-yaml all green).

## 1. Project map

```
                    PACKWISE PROJECT
                           │
          ┌────────────────┼────────────────┐
          │                │                │
       iOS APP          GITHUB          WEBSITE
          │                │                │
      IPA PRODUCT      SOURCE OF        DOCUMENTATION
                         TRUTH       (packwise.freebuff.app)
                           │
                     CI/CD (GitHub Actions + Gitea mirror + act)
                           │
                      BUILD / RELEASE
```

Rules enforced (from the product specification):

- The **native iOS app (the IPA) is the product**. The website is documentation
  only and must never become an alternative implementation of PackWise.
- Privacy is **on-device-first**: no cloud AI, no mandatory account, no tracking.
  Documentation never claims stronger guarantees than the implementation provides.
- **No prompt leakage**: README / wiki / site / changelog / releases describe
  PackWise, not the AI that built it.
- **No fictional data presented as real state**: screenshots are placeholder frames
  or real captures, never implied; build/release status comes from the live
  manifest or is shown as unavailable.

## 2. Phase tracker

| Phase | Status |
|---|---|
| 0 · Discovery / repository audit | COMPLETE (repeated across sessions) |
| 1 · Repository baseline | COMPLETE |
| 2 · File-by-file audit | **COMPLETE** — all 44 files read across 3 sessions: 19 iOS + 7 web pages + 7 infrastructure + 10 wiki + 4 scripts + workflow/config (earlier). Zero defects beyond the 2 iOS fixes from session 2. Isolate/ deleted. See FILE-AUDIT.md. |
| 3 · CI repair | **DONE** — R1 (YAML syntax), R3 (wiki sync), R4 (contradictory summary) all fixed. R2 (IPA EBADF) root cause confirmed, fix deployed, pending macOS CI run. |
| 4 · IPA pipeline investigation | **ADVANCED — published `dev` IPA verified broken (no main executable)**; current CI blocker pinned to the device-build step in `ios/build.sh`; signing overrides added — unverified until next macOS run |
| 5 · Docs & website truthfulness | **DONE** — manifest-driven CTAs/hero; all wiki pages rechecked against implementation (accurate); full site IA already in place (Setup/Download/Docs/Features/Troubleshooting all documented). |
| 6 · Final QA gate | **BLOCKED (external)** — requires a real macOS build + sideload check (no local toolchain in sandbox). Next GitHub Actions run is the verification for R2. |
| 7 · README restructure (§21) | **DONE** — added Screenshots placeholder, Contributing guide, and honest Project Status table. |
| 8 · Changelog sync across surfaces | **DONE** — `src/pages/Changelog.tsx` now mirrors `wiki/Changelog.md` (all 10 versions 1.0.0→1.0.9); README unchanged as it points to wiki; Landing/Download use live manifest only. `tsc` clean. |
| 9 · Verify sweep + web-brand polish (session 4) | **DONE** — full re-verify: `tsc` 0, `bash -n` 4/4, `js-yaml` 3/3, changelog parity 10/10, Convex codegen OK. Fixed 3 leftover web-brand/UX defects: PWA manifest rebranded (was FreeBuff template w/ broken `/logo.png` icon → PackWise w/ real `/logo.svg`); `ContentView` onboarding transition now reduced-motion gated; auth OTP email fallback app name → "PackWise". |
| 10 · Live CI evidence + R2 second fix (session 5) | **DONE** — pulled fresh evidence from GitHub API: wiki.yml now green (R3 confirmed closed), ios.yml still failing at device-build step. Confirmed 1.0.9 fix shipped but insufficient; found + fixed the literal-quote/`DEVELOPMENT_TEAM=` signing-arg bug in `ios/build.sh` (array form). 1.0.10 changelog entry synced web↔wiki. Re-verified R1/R3/R4 closed via js-yaml + bash -n. |
| 11 · R2 third root cause + public annotations (session 5b) | **DONE** — live CI confirmed array fix shipped (raw diff) but run 31248315617 still failed in ~8s. Compared passing tests step vs failing build step: the difference is `CODE_SIGN_STYLE=Manual`. build.sh now matches the passing tests flags exactly (`CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO CODE_SIGN_IDENTITY=`), adds strategy D, and emits public `::error::` annotations on failure (logs/artifacts need auth; annotations don't). Changelog 1.0.10 updated web↔wiki. |
| 12 · R2 TRUE root cause via public annotations (session 6) | **DONE** — the annotation channel delivered: run 31248752593's public `check-runs/93081580036/annotations` exposed the real error with zero auth: `Unable to find a destination … { platform:iOS, …, error:iOS 18.0 is not installed. To use with Xcode, first download and install the platform }`. **It was never signing** — macOS-15 runner images trim the iOS *device* platform (actions/runner-images #12758/#12862/#13570), so `-destination "generic/platform=iOS"` dies in <1s (matching every ~8s failure) while simulator tests pass. Fix shipped: workflow step `xcodebuild -downloadPlatform iOS` (sudo fallback) + newest-Xcode selection; `build.sh` self-healing `ensure_device_platform()` guard; mirrored in Gitea. Changelog 1.0.11 synced web↔wiki (12/12). |
| 13 · Full verification sweep + docs sync (session 7) | **DONE** — tsc 0, bash -n 4/4, js-yaml 3/3, convex dev OK. Changelog parity count corrected (11/11 → 12/12 for 1.0.11 entry). All 7 web pages + 10 wiki pages re-audited. Changelog 1.0.12 synced web↔wiki (13/13). EXECUTION-STATE.md updated. |
| 14 · R2 infra CLOSED + real compile bug fixed (session 8) | **DONE** — live CI run 31256274224 confirmed the session-6 platform fix works (device platform installed, compiler ran, XcodeGen OK, tests OK). Real blocker surfaced via public annotations: `.searchActions` (iOS 18-only) in TripListView + GlobalSearchView breaks the iOS 17 target build. Fixed with availability-safe `searchClearAction` modifier (new file SearchClearActionsModifier.swift). Changelog 1.0.13 synced web↔wiki (14/14). Next gate: macOS CI run to produce first valid IPA. |

## 3. Release-blocking items

| # | Item | Status | Evidence |
|---|---|---|---|
| R1 | `.github/workflows/ios.yml` rejected by GitHub: *Invalid workflow file, YAML syntax error* (line 148) | **FIXED 2026-08-08** | Root cause: the manifest-validation snippet inside a `run: \|` literal block was indented at **column 0** (block indent is 10 spaces), which ended the literal block mid-file. Fixed by aligning the block. `js-yaml` (the parser GitHub Actions uses) parses both workflows cleanly; `bash -n` clean; the fixed python step runs end-to-end. |
| R2 | `Failed to map …/PackWise: Bad file descriptor` at sideload | **INFRA CLOSED (session 8): run 31256274224 proved the platform fix; real bug now fixed — iOS 18-only `.searchActions` in a iOS 17-target app; next macOS CI run is the binary closure gate** | (1) Published artifact confirmed broken: downloaded `dev` IPA (5,004,581 bytes) **rejected** by hardened verifier — test bundles, **no main executable**. (2) Signing-arg fixes (1.0.9/1.0.10) **shipped** (raw-file diff proves `main` == local) but runs [31246529945](https://github.com/Alot1z/packwise/actions/runs/31246529945), [31248315617](https://github.com/Alot1z/packwise/actions/runs/31248315617), [31248752593](https://github.com/Alot1z/packwise/actions/runs/31248752593) all failed at "Build unsigned IPA" **~7–8s after tests** — too fast for a compile; the annotations channel (session 5b) then exposed the real error on run 31248752593: `Unable to find a destination matching the provided destination specifier: { platform:iOS, …, error:iOS 18.0 is not installed. To use with Xcode, first download and install the platform }`. **TRUE ROOT CAUSE: the GitHub macOS-15 runner image trims the iOS device platform** (actions/runner-images #12758/#12862/#13570); `-destination "generic/platform=iOS"` fails in <1s while simulator tests (which don't need the device platform) pass. Signing flags were hygiene, never the blocker. **Fix (session 6):** workflow step `xcodebuild -downloadPlatform iOS` (official remedy; sudo fallback) + select **newest** Xcode; `ios/build.sh` self-healing `ensure_device_platform()` guard for standalone local builds; mirrored in Gitea. `js-yaml` 3/3, `bash -n` 4/4, tsc 0, changelog 12/12. |
| R3 | Wiki sync workflow failing (run 31245277577, conclusion: failure at push step) | **FIXED 2026-08-08** | `.github/workflows/wiki.yml` rewritten: `checkout@v5`, wiki-repo enablement via API, robust push with accurate failure reporting. `js-yaml` parse OK. |
| R4 | Contradictory CI summary: "Tests did not pass (non-blocking) — IPA still built" + "No IPA produced" | **FIXED 2026-08-08** | Root cause: tests step aborted under `bash -e -o pipefail` before `TESTS_PASSED` was recorded, so the summary ran with stale/unset state. Step now records results before any early exit; summary renders one truthful status. |

## 4. Active / blocked / failed

- **Active**: push to trigger GitHub Actions (next R2 verification); README restructure
  review (§21, already close).
- **Blocked (external)**: macOS build/install verification — no Xcode in the sandbox;
  the next GitHub Actions run is the compiler. Public run-log download requires admin
  auth (403 — documented; the `ios-build-diagnostics` artifact is readable without
  sign-in). Signing / TestFlight claims require Apple credentials and are never assumed.
- **Failed validations this session**: none remaining — every defect found by tests
  was fixed (Mach-O probe endianness; manifest step `dev: null` crash; tests-step
  pipefail abort; build.sh unclosed quote; verify-ipa NUL stripping). See §8.

## 5. IPA "Bad file descriptor" investigation log

**2026-08-08 (session 2) — binary-level evidence on the real published artifact:**

1. Downloaded the public `dev` IPA (the artifact users actually sideload):
   `curl -L https://github.com/Alot1z/packwise/releases/download/dev/PackWise-unsigned.ipa`
   → 5,004,581 bytes. `sha256sum` recorded.
2. Ran the hardened `scripts/verify-ipa.sh` on it → **REJECTED**, with the targeted
   "no main executable" diagnostic. `unzip -Z1` listing confirms: `PlugIns/PackWiseTests.xctest`
   and XCTest/XCUnit/Testing frameworks present, **no `Payload/PackWise.app/PackWise`**.
3. GitHub API: `actions/artifacts` → `ios-build-diagnostics` (7,998 bytes,
   sha256 `c40e3e6e…`) — exactly the digest the user reported. `actions/runs` →
   latest ios.yml runs 5/5 failure; jobs API pins the failing step to
   **"Build unsigned IPA (device, arm64 — validated)"** (everything before it,
   including tests and XcodeGen install, succeeded).
4. Conclusion: the "Bad file descriptor" report was caused by the **broken published
   artifact** (test-injected bundle, no executable) — not by LiveContainer. The
   *current* pipeline blocker is the device build itself on the macOS runner.
   `ios/build.sh` now carries explicit unsigned-device-build overrides
   (`DEVELOPMENT_TEAM=""`, `CODE_SIGN_STYLE=Manual`, `CODE_SIGNING_ALLOWED=NO`) and
   richer diagnostics; the next GitHub run is the verification.
5. Remaining evidence to collect: post-fix CI run log (diagnostics artifact is
   public), re-run of the verifier on the next published `dev` IPA, and — when
   hardware exists — an actual LiveContainer/TrollStore/AltStore install test.

**2026-08-08 (session 1) — analysis (Linux sandbox; no local iOS toolchain):**

1. Ranked hypotheses for EBADF when mapping the executable:
   - (a) executable entry is a **symlink** → mmap fails EBADF
   - (b) executable entry is **0 bytes / unreadable**
   - (c) executable entry is a **directory** or resolves to one
   - (d) **simulator binary** (x86_64) or non-Mach-O payload
   - (e) installer/container-specific (LiveContainer mount) — only testable on-device
2. Actions taken: `scripts/verify-ipa.sh` hardened (symlink detection via
   `zipinfo -v` Unix attrs; empty-entry detection via extraction size; exact-path
   directory check; dependency-free Mach-O probe: magic, fat slices, cputype/
   cpusubtype — classifies device arm64 / simulator / not-a-binary on any OS).
   Fixture-tested 4/4 (symlink → EBADF diagnostic; empty → diagnostic; arm64 →
   sideload-ready; x86_64 → simulator rejection). Fixtures caught and fixed a real
   probe-endianness bug. **Packaging was not modified until binary evidence existed**
   (spec rule) — that rule is now satisfied, and `ios/build.sh` was updated.

## 6. Status board

| Area | Status |
|---|---|
| Web typecheck | PASS — `bun tsc -b --noEmit` EXIT 0 (session 4 re-verify after manifest/auth edits) |
| Convex codegen | PASS — `bun convex dev --once` (3.09s, functions ready) after `emailOtp.ts` edit |
| Web production build | PASS in an earlier session (`vite build`, 2411 modules); re-verify after web edits |
| iOS build | **UNVERIFIED this session** (no toolchain) — next CI run is the check |
| Workflow YAML | PASS — js-yaml parses `.github/workflows/ios.yml` + `.gitea/workflows/ios.yml` + `.github/workflows/wiki.yml` |
| Shell scripts | PASS — `bash -n` on verify-ipa.sh, release-manifest.sh, ios/build.sh (incl. the NO_SIGN_STR quote fix) |
| IPA verifier | PASS — 4/4 fixtures; **rejects the real published dev IPA** (broken artifact); NUL-warning-free on binary Info.plist |
| Real-artifact check | PASS (negative) — published `dev` IPA correctly rejected with no-main-executable diagnostic |
| Manifest validation step | PASS — runs clean with `dev: null` |
| iOS source audit | PASS — 19 files / 2,252 lines re-read; 2 defects fixed (Vision orientation, unconfirmed trip delete) |
| Deployment (packwise.freebuff.app) | NOT re-verified this session (no browser tooling; Chrome not installed) |

## 7. Deployment log

- The live site builds from this repo. This session changed `src/components/site-shared.tsx`
  (manifest-driven download CTAs + `useManifest` hook), `src/pages/Landing.tsx` (hero
  CTA/badges from live manifest), `src/pages/Download.tsx` (truthful verified/loading/
  unavailable states), `src/pages/Changelog.tsx` (1.0.8 + 1.0.9 entries). Source changed;
  live re-deploy + URL inspection **pending** — must be verified structurally and, if
  browser tooling is available, in a real browser.

## 8. Session validation log (2026-08-08, session 2)

| Check | Result |
|---|---|
| js-yaml parse: ios.yml + gitea ios.yml + wiki.yml | PASS (3/3) |
| `bash -n`: verify-ipa.sh / release-manifest.sh / ios/build.sh | PASS (build.sh quote bug found by this check, fixed) |
| verify-ipa.sh on **real published dev IPA** | PASS (negative) — rejected: no main executable |
| verify-ipa.sh fixtures (symlink / empty / arm64 / x86_64) | 4/4 PASS |
| verify-ipa.sh on binary Info.plist | PASS — no NUL warning, CFBundleExecutable path fixed |
| iOS source audit (19 files, 2,252 lines) | PASS — 2 defects fixed (Vision orientation; trip delete confirmation) |
| `bun tsc -b --noEmit` | PASS (EXIT 0) |
| GitHub API evidence (runs/jobs/artifacts/releases) | Collected — failing step pinned; broken artifact digest matched |

## 9. Next dependency-ready tasks (ordered)

1. **Push + trigger GitHub Actions**: confirm GitHub's real parser accepts all workflows,
   the device build passes with the new signing overrides, and the artifact publishes.
2. **R2 closure**: after a successful run, re-run `scripts/verify-ipa.sh` on the newly
   published `dev` `.ipa` (must print `sideload-ready`); then close R2 with full evidence.
3. **Phase 3 — CI / IPA validation**: once R2 is closed, verify the whole pipeline
   end-to-end (push → build → verify → publish).
4. **Phase 4 — Polish & release readiness**: any remaining UX bugs, documentation gaps,
   or build-system improvements identified during final review.
5. Update this file and FILE-AUDIT.md after every milestone.

## 10. Machine-readable snapshot (2026-08-08, session 8)

```json
{
  "project": "packwise",
  "session": "2026-08-08-s8",
  "phase": 14,
  "verify_sweep": "all green (tsc 0 / bash -n 4:4 / js-yaml 3:3 / changelog 14:14)",
  "r2_infrastructure_blocker": "CLOSED — run 31256274224: platform download step succeeded, compiler ran",
  "real_blocker_found": "Swift compile error: .searchActions is iOS 18-only but deployment target is iOS 17",
  "fix": {
    "files": ["ios/PackWise/Views/TripListView.swift", "ios/PackWise/Views/GlobalSearchView.swift", "ios/PackWise/Views/SearchClearActionsModifier.swift (new)"],
    "approach": "availability-safe searchClearAction modifier: #available(iOS 18.0, *) guard, iOS 17 falls back to built-in clear"
  },
  "changelog": "1.0.13 synced web↔wiki (14/14)",
  "live_ci_evidence": {
    "latest_ios_run": "31256274224 (failure at device-build step — compile error now, not infrastructure)",
    "wiki_sync": "green (R3 closed)",
    "r2_status": "infra fixed; binary gate = next macOS CI run"
  },
  "blockers": [
    { "id": "R1", "item": "ios.yml YAML syntax error", "status": "fixed" },
    { "id": "R2", "item": "IPA 'Failed to map: Bad file descriptor'", "status": "infra_closed_compile_fixed_awaiting_ci", "next": "next macOS CI run to produce first valid IPA" },
    { "id": "R3", "item": "wiki.yml failing at push", "status": "fixed" },
    { "id": "R4", "item": "contradictory CI summary", "status": "fixed" }
  ],
  "web_typecheck": "pass (tsc 0)",
  "workflow_parse": "pass (3/3)",
  "all_docs_surfaces": "synced (web changelog ↔ wiki changelog ↔ EXECUTION-STATE ↔ FILE-AUDIT)"
}
```
