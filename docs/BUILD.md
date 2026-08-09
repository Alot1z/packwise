# PackWise — Build

> How to build, test, and package the PackWise iOS app and its docs site.

## 1. Prerequisites

- macOS with Xcode (CI: macOS 15 image + newest installed Xcode; the runner downloads
  the iOS *device* platform via `xcodebuild -downloadPlatform iOS` when missing).
- [XcodeGen](https://github.com/yonaskolb/XcodeGen) (`brew install xcodegen`, or the
  workflow's Homebrew-free release-asset fallback).
- Bun (web docs site only).

## 2. Generate the project (never hand-edit the .xcodeproj)

```bash
cd ios
xcodegen generate
```

`ios/project.yml` is authoritative: targets, deployment targets, schemes, test
targets, signing style, `ENABLE_TESTABILITY: NO` (test bundles never ship).

## 3. Build & test (macOS)

```bash
cd ios
# Unit + UI tests (simulator, no signing)
xcodebuild test -project PackWise.xcodeproj -scheme PackWise \
  -destination "platform=iOS Simulator,name=iPhone 17,OS=latest" CODE_SIGNING_ALLOWED=NO

# Unsigned device IPA — same self-healing pipeline as CI
./build.sh     # → build/PackWise-unsigned.ipa + .sha256
```

`build.sh` strategies: A device build → B archive → C legacy build → D minimal build
(mirrors the passing tests invocation). Every candidate is validated: executable
exists, non-empty, arm64 Mach-O, `LC_BUILD_VERSION platform 2` (device, never 7 =
simulator); test bundles stripped; final `.ipa` must pass the strict publish gate or
the build fails loudly. Diagnostics → `build/diagnostics.txt` (CI uploads it even on
failure) and `::error::` annotation lines (publicly readable).

## 4. Verify any IPA (any OS — even Linux)

```bash
./scripts/verify-ipa.sh <file>   # .ipa, artifact .zip (auto-unwrap), or folder
```

Checks: zip integrity → `Payload/PackWise.app` exists → arm64 device Mach-O → no
`*.xctest`/XCTest frameworks → main executable non-empty.

## 5. Web docs site (Vite + React + Convex)

```bash
bun install
bun tsc -b --noEmit      # typecheck
bun run build            # → dist/
```

`vercel.json` handles SPA rewrites, `assets/` immutable caching, `cleanUrls`. Convex
codegen: `bun convex dev --once` (after touching `src/convex/`).

## 6. Pre-flight before tagging a release (3 checks, ≤ 15 s)

```bash
bun tsc -b --noEmit
bash -n scripts/verify-ipa.sh scripts/release-manifest.sh
npx js-yaml .github/workflows/ios.yml > /dev/null
git tag vX.Y.Z -m "PackWise X.Y.Z" && git push origin vX.Y.Z
```

## 7. Three equal build hosts

1. GitHub Actions (hosted, `macos-15`) — pushes to `main` + `v*` tags.
2. Gitea Actions (self-hosted mirror `.gitea/workflows/ios.yml`, `runs-on: macos`).
3. `act` locally on macOS (`brew install act && act -W .github/workflows/ios.yml -P macos-15=-self-hosted`).

All three share `ios/build.sh` + `scripts/verify-ipa.sh` — same artifact, same gate.
