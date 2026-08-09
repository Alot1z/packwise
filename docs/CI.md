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

Two jobs run in **parallel**:

```
web-static-validation (ubuntu)   build-and-test (macos)
  ├─ setup bun                    ├─ environment recording
  ├─ bun install (cached)         ├─ select newest Xcode (deterministic)
  ├─ tsc -b --noEmit              ├─ restore iOS device platform (cached)
  ├─ bun run build                ├─ downloadPlatform iOS (fallback)
  └─ bash -n + js-yaml            ├─ XcodeGen (cached, pinned 2.46.0)
                                  ├─ xcodegen generate (::error:: on failure)
                                  ├─ tests (simulator, non-blocking)
                                  ├─ build.sh cascade → verify-ipa.sh → manifest
                                  └─ publish dev / v* Release ONLY if gate passed
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

## 2b. Caching strategy (warm CI)

| Resource | Strategy | Cache key | Invalidation |
|---|---|---|---|
| Xcode | Runner-provided — never downloaded | — | — |
| iOS device platform | Cached, restored with sudo, **validated** (`xcodebuild -showsdks`), download fallback | `ios-platform-{os}-{arch}-{Xcode version}` | Xcode version changes |
| XcodeGen | Cached binary, pinned 2.46.0, version verified every run | `xcodegen-{os}-2.46.0` | version bump |
| Bun deps | Cached install cache | `bun-{os}-{lockfile hash}` | `bun.lock` / `package.json` change |
| DerivedData / SPM | **Intentionally not cached** — archive always compiles fresh so stale objects can never hide a source regression | — | — |
| IPA / release artifacts | **Always freshly produced** by the current commit's build | — | — |
| Signing credentials | Secrets — never cached | — | — |

Cache correctness contract: clean cache → build succeeds; warm cache → build succeeds;
changed dependency → correct invalidation; corrupt cache → validation catches it and
falls back to the fresh path. Caching is an optimization layer, never a correctness
requirement.

## 3. Failure semantics

- `exit 0` = success, non-zero = failure, on every required step.
- On failure: `::error::` workflow-command annotations are emitted by `build.sh`
  (public via `check-runs/{id}/annotations` — no auth), and the
  `ios-build-diagnostics` artifact (build.log, tests.log, ci.log, diagnostics.txt)
  is uploaded with `if: always()`.
- Diagnostic collection never converts a failed build into a green run.

## 4. Current CI state (evidence)

- **2026-08-09 (session 14):** run [31317701450](https://github.com/Alot1z/packwise/actions/runs/31317701450)
  failed at **Generate Xcode project** in 0 seconds. Root cause: invalid
  `options.entitlements` key in `ios/project.yml` (XcodeGen spec rejects unknown
  option keys) — **fixed** by moving entitlements to targets only. Also removed
  nonstandard `sdk:` framework deps from the Widget target (auto-linked).
  Workflow redesigned for warm CI: parallel web-validation job, XcodeGen + Bun +
  device-platform caches, public `::error::` annotations on the xcodegen step.
- **Pending:** the next macOS CI run must pass XcodeGen generation (project.yml
  fix), then compile the iOS-18-targeted Swift (camera / subject-extraction /
  weather / destination-search / widgets / app-intents). That run is the acceptance
  criterion — see `docs/FULLPACK-CAPABILITY-MATRIX.md` status column.

## 5. Versioning & release

- `MARKETING_VERSION` (project.yml) ↔ git tag `v*` ↔ manifest — kept coherent.
- `scripts/release-manifest.sh` writes `PackWise-releases.json` with
  `verified_by_build: true` **only** when the current build passed the verifier.
- Two stable manifest URLs, no API key: `releases/latest/download/…` and
  `releases/download/dev/…`.
