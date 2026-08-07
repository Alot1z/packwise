# Troubleshooting

## "I downloaded a .zip but expected a .ipa"

**Not a PackWise bug — GitHub wraps artifacts.** `actions/upload-artifact` always delivers downloads as an outer container zip. Inside `PackWise-unsigned-ipa.zip` is the real `PackWise-unsigned.ipa`.

| You used | File you got | What to do |
|---|---|---|
| **Releases → Latest** or **`releases/tag/dev`** | `PackWise-unsigned.ipa` directly | Sideload it — no unwrap |
| **Actions → artifact** | `PackWise-unsigned-ipa.zip` (outer container) | Download → **unzip once** → `PackWise-unsigned.ipa` inside → sideload that |

> Every push to `main` now also publishes a **`dev` prerelease** with the direct `.ipa` (`releases/tag/dev`) so you never need to unwrap if you don't want to. Tags `v*` publish versioned Releases.

**Verify any download (one command — auto-unwraps artifact zips):**

```bash
./scripts/verify-ipa.sh <downloaded-file>   # → "✓ sideload-ready" or exactly why not
```

Or manually:

```bash
file PackWise-unsigned.ipa          # → Zip archive data (correct — .ipa IS a zip renamed)
unzip -l PackWise-unsigned.ipa | head  # → Payload/PackWise.app/ ...
shasum -a 256 PackWise-unsigned.ipa
```

Direct download without unwrapping:

```bash
gh release download dev -R Alot1z/packwise -p "PackWise-unsigned.ipa"
curl -L -o PackWise-unsigned.ipa https://github.com/Alot1z/packwise/releases/download/dev/PackWise-unsigned.ipa
```

## "Failed to map …/PackWise: Bad file descriptor" (sideload fails)

**Root cause (confirmed by inspecting the published IPA):** the earlier `dev` build was packaged **without its main executable** — the bundle contained only `Info.plist`, `Assets.car`, `PkgInfo`, plus **injected test bundles** (`PlugIns/PackWiseTests.xctest`, `XCTest`/`XCUnit`/`XCUIAutomation`/`Testing` frameworks). The sideloader can't map a binary that isn't there.

**Fix (already in repo):** `ios/build.sh` now tries **three strategies** (device build → archive → legacy build), validates that `Payload/PackWise.app/PackWise` exists, is non-empty, is arm64 Mach-O with `LC_BUILD_VERSION platform 2`, strips all test injection, and **refuses to publish** anything that fails. Download the latest [`dev`](https://github.com/Alot1z/packwise/releases/tag/dev) build (or run `./ios/build.sh` locally) and verify before sideloading:

```bash
unzip -l PackWise-unsigned.ipa | grep -E "Payload/PackWise.app/(PackWise|Info.plist)"  # both must appear
unzip -l PackWise-unsigned.ipa | grep -iE "xctest|XCTest|XCUnit" || echo "clean ✓"
shasum -a 256 PackWise-unsigned.ipa
```

**Old failure logs:** [#31163718082](https://github.com/Alot1z/packwise/actions/runs/31163718082) (tests blocked the old archive step — now non-blocking) and [#31164548645](https://github.com/Alot1z/packwise/actions/runs/31164548645) (outer zip vs direct `.ipa` — now a `dev` prerelease ships the direct `.ipa`).

## "Run tests (simulator, no signing): failure" but IPA missing

Before the fix, archive had no `if: always()` so test failure skipped the IPA entirely. Now tests are non-blocking — the IPA still builds. Pull `main` if you see old behavior.

## Build step failed (exit 1)? Where are the logs?

- The **`ios-build-diagnostics` artifact** (uploaded on every run, kept 30 days) contains `build.log`, `tests.log`, `ci.log` and `diagnostics.txt` — no sign-in needed.
- The run **Summary** shows the last 60 lines of `diagnostics.txt` on failure.
- The most common cause on Xcode 16 is the no-signing quirk (missing executable / test injection) — the cascade + gate in `ios/build.sh` handles it; a genuinely failing build now prints exactly why.

## AltStore / Sideloadly: "Untrusted Developer" / install fails

Unsigned IPAs must be re-signed. AltStore/Sideloadly → Apple ID for local signing. TrollStore → + → select IPA (where supported). Then *Settings → General → VPN & Device Management* → trust. The `.ipa` you sideload must be the inner `PackWise-unsigned.ipa`, not the outer artifact zip.

## "Vision finds nothing"

Vision is on-device and conservative (`confidence > 0.15`, top 8). Try a clearer, well-lit photo, closer crop, or add manually — scanner always has a manual fallback.

## Wiki not updating

- Enable Wiki: *Settings → Features → Wikis*
- Workflow `Wiki — Sync` runs on pushes to `wiki/**`, `README.md`, `assets/**` — or *Actions → Wiki — Sync → Run workflow*
- Pushes to `Alot1z/packwise.wiki.git` with `GITHUB_TOKEN`

## iOS build warnings (not failures)

```
Node.js 20 is deprecated. ... actions/checkout@v4 → Node 24 : warning only
brew tap trust (aws/tap)                                     : warning only
```

Informational — build still succeeds.

## Need live logs?

- **Latest runs:** [Actions → iOS — PackWise](https://github.com/Alot1z/packwise/actions)
- **Direct .ipa:** [Releases — Latest](https://github.com/Alot1z/packwise/releases/latest) · [dev](https://github.com/Alot1z/packwise/releases/tag/dev)
- **Artifact (unwrap):** Actions → `PackWise-unsigned-ipa` (14 days)
