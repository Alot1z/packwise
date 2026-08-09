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
→ XcodeGen install/verify → xcodegen generate
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

## 3. Failure semantics

- `exit 0` = success, non-zero = failure, on every required step.
- On failure: `::error::` workflow-command annotations are emitted by `build.sh`
  (public via `check-runs/{id}/annotations` — no auth), and the
  `ios-build-diagnostics` artifact (build.log, tests.log, ci.log, diagnostics.txt)
  is uploaded with `if: always()`.
- Diagnostic collection never converts a failed build into a green run.

## 4. Current CI state (evidence)

- Swift compile of the existing 20-file app: **PASSED** on the macOS runner
  (Xcode 26.3 / iOS 26.2 SDK, target iOS 17.0) after the nonexistent
  `.searchActions` API was removed.
- The last failure was IPA staging (`validate_app` stdout pollution) — fixed; the
  next macOS run is the gate for the current artifact.
- **Pending:** macOS CI validation of the new camera / subject-extraction / weather /
  destination-search Swift added in the FullPack reconstruction. That run is the
  acceptance criterion — see `docs/FULLPACK-CAPABILITY-MATRIX.md` status column.

## 5. Versioning & release

- `MARKETING_VERSION` (project.yml) ↔ git tag `v*` ↔ manifest — kept coherent.
- `scripts/release-manifest.sh` writes `PackWise-releases.json` with
  `verified_by_build: true` **only** when the current build passed the verifier.
- Two stable manifest URLs, no API key: `releases/latest/download/…` and
  `releases/download/dev/…`.
