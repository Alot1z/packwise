# CI Validation — Live Gate State

> **Authority:** the macOS GitHub runner is the only iOS compiler that counts
> (Linux/Windows cannot compile iOS). Web gates (`tsc`, `vite build`) run on any
> platform and are checked locally.
>
> Rule: **nothing is COMPLETE until a green GitHub run has produced a validated
> unsigned IPA.** Status rows below are rewritten after every run.

## iOS gate — `iOS — PackWise` (.github/workflows/ios.yml)

| Run / commit | Result | Blocker |
|---|---|---|
| Runs 31318328750 … 31335236278 (25 consecutive) | ❌ failure | See below — every recent run failed |
| `b32acec` (App Intents `\\(`→`\\(` escape fix) | ❌ failure | Swift 6 strict-concurrency errors (the escape fix was real but not the blocker) |

**Current blocker (from public check-run annotations of run 31335236278):**

1. `CameraService.swift:57` — `deinit` accessed non-Sendable `AVCaptureSession` from
   nonisolated deinit → **FIXED on disk** (deinit removed; session stops on dealloc).
2. `CameraService.swift:188` — `sending 'self' risks causing data races` in the
   photo-capture callback → **FIXED on disk** (`Task { @MainActor }` hop).
3. `DestinationSearchService.swift:86` — `sending 'results' risks causing data races`
   (`MKLocalSearchCompletion` → MainActor task) → **FIXED on disk** (`@preconcurrency import MapKit`).

**Uncommitted on disk (need commit + push):** the two Swift files above,
`.github/workflows/wiki.yml` (read-only token fix), `.env.example`,
`src/convex/auth/emailOtp.ts` (env var), `src/convex/packing.ts` (typed ctx),
`wiki/Convex-Reference.md`, `docs/FULLPACK-CAPABILITY-MATRIX.md`.

**Next run must show:** `Generate Xcode project` ✅ → `Build unsigned IPA` ✅ →
`Verify IPA (publish gate)` ✅ → artifact `PackWise-unsigned-ipa` uploaded.
If new Swift 6 diagnostics appear, the next suspects are the
`sessionQueue.async { [weak self] ... }` closures in `CameraService.start()/stop()/flipCamera()`.

## Wiki gate — `Wiki — Sync` (.github/workflows/wiki.yml)

- 14 recent runs: ✅ green — but **green was a lie**: the push step had
  `continue-on-error: true` and the token was read-only, so `Alot1z/packwise.wiki`
  was never updated (raw `Home.md` → 404).
- **FIXED on disk:** added `permissions: contents: write` and removed
  `continue-on-error` so a failed sync red-flags.
- Next run must show `✓ Wiki synced` and `https://raw.githubusercontent.com/wiki/Alot1z/packwise/Home.md` → 200.

## Web gates (local, Windows-valid)

- `bun tsc -b --noEmit` → ✅ pass (current main + all on-disk changes).
- `bun run build` → ✅ pass (2411 modules, ~17s; node_modules was repaired with `bun install`).
- `bun run dev` + preview → ✅ serves; see docs below.

## Release gate

- `releases/tag/dev` **has a verified build** (2026-08-09 10:15 UTC, sha256
  `8b1287b0…b7`, 826 KB). Downloaded and re-verified locally with
  `scripts/verify-ipa.sh` → **✓ sideload-ready** (valid zip,
  `Payload/PackWise.app/PackWise`, arm64 device Mach-O, no test bundles,
  unsigned as expected). The README download links work today.
- The dev build is **stale**: the 7 runs published after it (18:47–20:49 UTC)
  all failed on the Swift 6 errors now fixed on disk. Fresh builds resume once
  the fixes pass CI.
- `releases/latest` (tag `v*`) is empty — no tagged release yet.
- Browser caveat (fixed on disk): the site used to fetch the release manifest
  from `releases/download/…`, which GitHub serves without CORS headers, so the
  browser always errored and the site could never show the verified state. It
  now reads the CORS-enabled REST API (`api.github.com`) and requires an actual
  IPA asset (size > 100 KB) before showing “verified”.

## Definition of done (per master directive §46–§47)

- [ ] iOS: XcodeGen → compile → tests → archive → IPA → verify-ipa.sh, all green
- [ ] Wiki: syncs on push; raw Home.md 200
- [ ] Web: tsc + build green; preview serves
- [ ] Convex: `npx convex` typecheck/deploy clean
- [ ] Release: `dev` prerelease with direct `.ipa` exists
- [ ] No required CI step bypassed (`continue-on-error`, `|| true` on gates)
- [ ] Final classification reported with the run ID + commit SHA (never COMPLETE on static checks alone)
