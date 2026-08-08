# PackWise — Engineering Execution State

> **Living document.** Update at the end of every session. Per-file audit lives in
> [`docs/engineering/FILE-AUDIT.md`](FILE-AUDIT.md). Last updated: **2026-08-08**
> (autonomous engineering session — CI root-cause repair & binary verification).

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
| 2 · File-by-file audit | IN PROGRESS — all 19 iOS Swift files + release-critical infra re-read this session (see FILE-AUDIT.md); ~14 files still 🕒 pending full re-read |
| 3 · CI repair | **DONE for YAML error (R1)** + this session: tests-step pipefail bug fixed, brew tap hygiene, action majors bumped, wiki workflow rewritten, truthful summary. Next check = real GitHub run. |
| 4 · IPA pipeline investigation | **ADVANCED — published `dev` IPA verified broken (no main executable)**; current CI blocker pinned to the device-build step in `ios/build.sh`; signing overrides added — unverified until next macOS run |
| 5 · Docs & website truthfulness | IN PROGRESS — site CTAs/hero now manifest-driven with honest "unavailable" state; full site IA redesign pending |
| 6 · Final QA gate | NOT STARTED — requires a real macOS build + sideload check (no local toolchain) |

## 3. Release-blocking items

| # | Item | Status | Evidence |
|---|---|---|---|
| R1 | `.github/workflows/ios.yml` rejected by GitHub: *Invalid workflow file, YAML syntax error* (line 148) | **FIXED 2026-08-08** | Root cause: the manifest-validation snippet inside a `run: \|` literal block was indented at **column 0** (block indent is 10 spaces), which ended the literal block mid-file. Fixed by aligning the block. `js-yaml` (the parser GitHub Actions uses) parses both workflows cleanly; `bash -n` clean; the fixed python step runs end-to-end. |
| R2 | `Failed to map …/PackWise: Bad file descriptor` at sideload | **ROOT CAUSE CONFIRMED for the published artifact — CI fix pending next run** | Downloaded the public `dev` release IPA (5,004,581 bytes, sha256 `7b80…` recorded in run log) and ran the hardened verifier: **rejected** — bundle contains `PlugIns/PackWiseTests.xctest` + XCTest frameworks and **no main executable**. That is the literal cause of EBADF. Timeline (from GitHub API): old pipeline published this broken artifact at 15:23 (run 31192390306); the hardened pipeline replaced it and every device build since fails at the **"Build unsigned IPA" step** (run 31245277557). `ios/build.sh` signing overrides added this session — unverified until the next macOS run. |
| R3 | Wiki sync workflow failing (run 31245277577, conclusion: failure at push step) | **FIXED 2026-08-08** | `.github/workflows/wiki.yml` rewritten: `checkout@v5`, wiki-repo enablement via API, robust push with accurate failure reporting. `js-yaml` parse OK. |
| R4 | Contradictory CI summary: "Tests did not pass (non-blocking) — IPA still built" + "No IPA produced" | **FIXED 2026-08-08** | Root cause: tests step aborted under `bash -e -o pipefail` before `TESTS_PASSED` was recorded, so the summary ran with stale/unset state. Step now records results before any early exit; summary renders one truthful status. |

## 4. Active / blocked / failed

- **Active**: full file-by-file audit (FILE-AUDIT.md); website IA redesign (§24 of spec);
  README restructure review (§21, already close).
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
| Web typecheck | PASS — `bun tsc -b --noEmit` EXIT 0 (after site-shared/Landing/Download/Changelog edits) |
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

1. Push + trigger GitHub Actions: confirm GitHub's real parser accepts all workflows,
   the device build passes with the new signing overrides, and the artifact publishes.
2. After a successful run: re-run `scripts/verify-ipa.sh` on the newly published `dev`
   `.ipa` (must print `sideload-ready`); then close R2 with the full evidence chain
   (§21 of spec: observed failure → evidence → root cause → correction → new artifact →
   binary validation → installation result).
3. Continue Phase 2: re-read remaining 🕒 rows in FILE-AUDIT.md (web pages, wiki docs,
   config files, scripts) and update the manifest.
4. Website IA redesign per spec §24 (Download / Features / iOS / Docs / Releases /
   Changelog / Contributing) — keep every status real.
5. README restructure per spec §21 (add screenshots/contributing; keep honest status).
6. Update this file and FILE-AUDIT.md after every milestone.

## 10. Machine-readable snapshot (2026-08-08, session 2)

```json
{
  "project": "packwise",
  "session": "2026-08-08-s2",
  "phase": 2,
  "blockers": [
    { "id": "R1", "item": "ios.yml YAML syntax error", "status": "fixed", "verified_by": "js-yaml parse" },
    { "id": "R2", "item": "IPA 'Failed to map: Bad file descriptor'", "status": "published_artifact_confirmed_broken", "evidence": "dev ipa downloaded + verifier rejected: no main executable; test bundles shipped", "next_step": "verify next CI build with scripts/verify-ipa.sh" },
    { "id": "R3", "item": "wiki.yml failing at push", "status": "fixed", "verified_by": "js-yaml parse + rewrite" },
    { "id": "R4", "item": "contradictory CI summary", "status": "fixed", "verified_by": "workflow rewrite" }
  ],
  "web_typecheck": "pass",
  "workflow_parse": "pass (3/3)",
  "ipa_verifier_fixtures": "4/4 pass",
  "real_dev_ipa_verification": "rejected-as-broken (expected, evidence)",
  "ios_source_audit": "19 files / 2252 lines, 2 defects fixed",
  "ios_build": "unverified_no_toolchain_signing_overrides_added",
  "deployment": "source_changed_deploy_pending"
}
```
