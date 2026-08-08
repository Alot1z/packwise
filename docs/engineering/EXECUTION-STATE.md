# PackWise — Engineering Execution State

> **Living document.** Update at the end of every session. Per-file audit lives in
> [`docs/engineering/FILE-AUDIT.md`](FILE-AUDIT.md). Last updated: **2026-08-08**
> (autonomous engineering session).

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
| 2 · File-by-file audit | IN PROGRESS — see FILE-AUDIT.md (release-critical paths audited this session; ~45 files pending full re-read) |
| 3 · CI repair | DONE for the blocking YAML error (fixed, js-yaml-verified) — workflow re-reviewed end to end |
| 4 · IPA pipeline investigation | IN PROGRESS — root-cause log §5; verifier hardened + fixture-tested; packaging untouched until binary evidence exists |
| 5 · Docs & website truthfulness | IN PROGRESS — fake-data pass done; full site IA redesign pending |
| 6 · Final QA gate | NOT STARTED — requires a real macOS build + sideload check (no local toolchain) |

## 3. Release-blocking items

| # | Item | Status | Evidence |
|---|---|---|---|
| R1 | `.github/workflows/ios.yml` rejected by GitHub: *Invalid workflow file, YAML syntax error* (line 148) | **FIXED 2026-08-08** | Root cause: the manifest-validation snippet inside a `run: \|` literal block was indented at **column 0** (block indent is 10 spaces), which ended the literal block mid-file. Fixed by aligning the block. `js-yaml` (the parser GitHub Actions uses) parses both workflows cleanly; `bash -n` clean on all scripts; the fixed python step runs end-to-end. |
| R2 | `Failed to map …/PackWise: Bad file descriptor` at sideload | **INVESTIGATING — see §5** | Historical root cause (1.0.1, verified by inspecting a published IPA): test-injection produced a bundle with **no main executable**. Pipeline now validates before publish. The LiveContainer report must be re-checked against the newest `dev` build with the hardened verifier. |

## 4. Active / blocked / failed

- **Active**: full file-by-file audit (FILE-AUDIT.md); website IA redesign (§24 of spec);
  README restructure review (§21, already close).
- **Blocked (external)**: macOS build/install verification — no Xcode in the sandbox;
  the next GitHub Actions run is the compiler. Signing / TestFlight claims require
  Apple credentials and are never assumed.
- **Failed validations this session**: none remaining — two defects found by fixture
  tests were fixed (Mach-O probe endianness; manifest step `dev: null` crash). See §8.

## 5. IPA "Bad file descriptor" investigation log

**2026-08-08 — analysis (Linux sandbox; no local iOS toolchain; no published IPA on disk):**

1. Ranked hypotheses for EBADF when mapping the executable:
   - (a) the executable entry inside the zip is a **symlink** (dangling or not) → mmap fails EBADF
   - (b) the executable entry is **0 bytes / unreadable** → nothing to map
   - (c) the executable entry is a **directory** or the path resolves to one
   - (d) **simulator binary** (x86_64) or a non-Mach-O payload → different failure class, still a broken artifact
   - (e) installer/container-specific (LiveContainer mount) → only testable on-device
2. Actions taken:
   - `scripts/verify-ipa.sh` hardened: detects (a) from zip metadata
     (`zipinfo -v` Unix attrs — bare `unzip -Z1` does **not** reveal symlinks),
     (b) via extraction size, and (c) via exact-path match; plus a dependency-free
     **Mach-O probe** (magic, fat slices, cputype/cpusubtype) that classifies any
     artifact on any OS — device arm64, simulator, or not-a-binary.
   - Fixture-tested (4 artifacts): symlink → targeted EBADF diagnostic; empty →
     targeted diagnostic; arm64 thin → `sideload-ready`; x86_64 → simulator rejection.
   - **NOT modified**: `ios/build.sh` packaging (spec: don't touch packaging until the
     binary itself is inspected).
3. Evidence still needed:
   - Run `./scripts/verify-ipa.sh` on the exact `.ipa` LiveContainer rejected.
   - Or on the newest dev build:
     `curl -L -o /tmp/pw.ipa https://github.com/Alot1z/packwise/releases/download/dev/PackWise-unsigned.ipa && ./scripts/verify-ipa.sh /tmp/pw.ipa`

## 6. Status board

| Area | Status |
|---|---|
| Web typecheck | PASS — `bun tsc -b --noEmit` EXIT 0 (after Landing/Changelog edits) |
| Web production build | PASS in an earlier session (`vite build`, 2411 modules); re-verify after web edits |
| iOS build | **UNVERIFIED this session** (no toolchain) — next CI run is the check |
| Workflow YAML | PASS — js-yaml parses `.github/workflows/ios.yml` + `.gitea/workflows/ios.yml` |
| Shell scripts | PASS — `bash -n` on verify-ipa.sh, release-manifest.sh, ios/build.sh |
| IPA verifier | PASS — 4/4 fixture outcomes correct (symlink → EBADF diagnostic; empty → diagnostic; arm64 → sideload-ready; x86_64 → simulator rejection) |
| Manifest validation step | PASS — runs clean with `dev: null` (was crashing) |
| Deployment (packwise.freebuff.app) | NOT re-verified this session (no browser tooling; Chrome not installed) |

## 7. Deployment log

- The live site builds from this repo. This session changed `src/pages/Landing.tsx`
  (truthfulness labeling) and `src/pages/Changelog.tsx` (1.0.7 sync). Source changed;
  live re-deploy + URL inspection **pending** — must be verified structurally and, if
  browser tooling is available, in a real browser.

## 8. Session validation log (2026-08-08)

| Check | Result |
|---|---|
| js-yaml parse, both workflows | PASS |
| `bash -n` verify-ipa.sh / release-manifest.sh / ios/build.sh | PASS |
| verify-ipa.sh fixtures: symlink / empty / arm64 / x86_64 | **4/4 PASS** — each rejected or accepted with the correct, targeted diagnostic |
| release-manifest.sh smoke + workflow python step | PASS after `(m.get('dev') or {})` hardening (prints `dev= None` cleanly) |
| `bun tsc -b --noEmit` | PASS (EXIT 0) |
| Mach-O probe endianness | FIXED + verified (arm64 accepted, x86_64 rejected) |

## 9. Next dependency-ready tasks (ordered)

1. Push + trigger GitHub Actions: confirm GitHub's real parser accepts the workflow,
   the IPA builds, and the artifact publishes.
2. Run the hardened `verify-ipa.sh` against the newest `dev` `.ipa`; close or escalate R2.
3. Continue Phase 2: re-read every iOS Swift file + web page (rows marked 🕒 in FILE-AUDIT.md).
4. Website IA redesign per spec §24 (Download / Features / iOS / Docs / Releases / Changelog /
   Contributing) — keep every status real.
5. README restructure per spec §21 (add screenshots/contributing; keep honest status).
6. Update this file and FILE-AUDIT.md after every milestone.

## 10. Machine-readable snapshot (2026-08-08)

```json
{
  "project": "packwise",
  "session": "2026-08-08",
  "phase": 2,
  "blockers": [
    { "id": "R1", "item": "ios.yml YAML syntax error", "status": "fixed", "verified_by": "js-yaml parse" },
    { "id": "R2", "item": "IPA 'Failed to map: Bad file descriptor'", "status": "investigating", "next_step": "verify newest dev ipa with scripts/verify-ipa.sh" }
  ],
  "web_typecheck": "pass",
  "workflow_parse": "pass",
  "ipa_verifier_fixtures": "4/4 pass",
  "ios_build": "unverified_no_toolchain",
  "deployment": "source_changed_deploy_pending"
}
```
