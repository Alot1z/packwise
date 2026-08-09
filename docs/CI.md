# PackWise — CI

> The authoritative remote iOS execution environment is **GitHub Actions on a macOS
> runner**. Linux-side static checks are useful; the real Xcode compiler is the gate.

## 1. Workflows

| Workflow | Trigger | Purpose |
|---|---|---|
| `.github/workflows/ios.yml` | push `main`, `v*` tags, manual dispatch | Build + validate + publish the unsigned IPA |
| `.github/workflows/wiki.yml` | push `wiki/**`, README, assets | Sync `wiki/` → `Alot1z/packwise.wiki` |
| `.gitea/workflows/ios.yml` | mirror | Same pipeline on self-hosted Gitea macOS |

## 2. iOS pipeline (ios.yml)

```
checkout → environment recording (sw_vers, xcodebuild -version, -showsdks, swift --version)
→ select newest Xcode (deterministic) → xcodegen generate (::error:: on failure — public annotations)
→ (missing device platform?) xcodebuild -downloadPlatform iOS (sudo fallback)
→ tests (simulator, no signing, non-blocking — dynamic iPhone discovery)
→ build.sh cascade → verify-ipa.sh strict gate → release-manifest.sh
→ upload ios-build-diagnostics artifact (always) + PackWise-unsigned.ipa artifact
→ publish dev prerelease / v* Release ONLY if the gate passed
```

Design rules (hard requirements):

- Compilation, archive, IPA creation, IPA verification and release publishing are
  **blocking** — no `continue-on-error`, no `|| true` on required steps.
- Tests are **informational** by product decision; a test failure never implies tests
  passed, and never blocks the IPA. Policy is documented in the workflow summary.
- The `xcode_version` input actually selects the **runner image**; the workflow then
  picks the **newest installed Xcode** on it and records the real environment.
- A failed run publishes **nothing** — previous artifacts are never presented as the
  result of a failed run. The summary states explicitly "no IPA published".
- Failures at the XcodeGen gate carry `::error::` annotations so the root cause is
  readable via the public `check-runs/{id}/annotations` endpoint without sign-in.
- The `xcodegen generate` step is a hard gate: the workflow never claims Swift
  compiled when XcodeGen never ran.

## 2b. Cache architecture (design — verification pending)

Caching is planned as an **optimization layer**, never a correctness requirement.
A previous caching redesign was rejected by GitHub's workflow parser; it will be
re-introduced incrementally with schema validation (e.g., `actionlint`) per change.

Intended classification:

| Resource | Intended strategy |
|---|---|
| Xcode | Runner-provided — never downloaded |
| iOS device platform | Cached by Xcode version, restored with sudo, validated via `xcodebuild -showsdks`, download fallback |
| XcodeGen | Cached binary, pinned 2.46.0, version verified every run |
| Bun deps | Cached install cache, lockfile-keyed |
| DerivedData / SPM | **Intentionally not cached** — archive always compiles fresh so stale objects can never hide a source regression |
| IPA / release artifacts | Always freshly produced by the current commit's build |
| Signing credentials | Secrets — never cached |

## 3. Failure semantics

- `exit 0` = success, non-zero = failure, on every required step.
- On failure: `::error::` workflow-command annotations are emitted by `build.sh`
  (public via `check-runs/{id}/annotations` — no auth), and the
  `ios-build-diagnostics` artifact (build.log, tests.log, ci.log, diagnostics.txt)
  is uploaded with `if: always()`.
- Diagnostic collection never converts a failed build into a green run.

## 4. Current CI state (evidence)

- **2026-08-09 (session 14 & dual-CI recovery):** run [31317701450](https://github.com/Alot1z/packwise/actions/runs/31317701450)
  failed at **Generate Xcode project** in 0 seconds. Root cause: invalid
  `options.entitlements` key in `ios/project.yml` (XcodeGen spec rejects unknown
  option keys) — fixed by moving entitlements to targets only. Also removed
  nonstandard `sdk:` framework deps from the Widget target (auto-linked). A
  subsequent commit (734d974) introduced a workflow file rejected by GitHub's
  parser (0 jobs = workflow-level validation failure, distinct from a job
  failure); it was detected because the failing push's iOS run had `total_count
  0` jobs while Wiki at the same SHA passed. The fix was to keep reliability
  changes surgical (public `::error::` on the xcodegen gate + dynamic simulator
  discovery in Gitea) and land the parallel-job/caching redesign from a green
  baseline with schema validation. Workflow restored to known-good shape; the
  project.yml spec fix is the authoritative gate.
- **Pending:** the next macOS CI run must pass XcodeGen generation (project.yml
  spec fix), then compile the iOS-18-targeted Swift. That run is the acceptance
  criterion — see `docs/FULLPACK-CAPABILITY-MATRIX.md` status column.

## 5. Versioning & release

- `MARKETING_VERSION` (project.yml) ↔ git tag `v*` ↔ manifest — kept coherent.
- `scripts/release-manifest.sh` writes `PackWise-releases.json` with
  `verified_by_build: true` **only** when the current build passed the verifier.
- Two stable manifest URLs, no API key: `releases/latest/download/…` and
  `releases/download/dev/…`.
