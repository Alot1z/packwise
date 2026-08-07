# Troubleshooting

## “Archive did not produce an app bundle. No IPA artifact.”

**Seen on:** `macos-15` + Xcode 16 + `CODE_SIGNING_ALLOWED=NO` — archive exits 0 but creates no `.app`.

**Fix (already in repo):** The workflow now falls back to `xcodebuild build -destination generic/platform=iOS -derivedDataPath build/DerivedData` if the xcarchive is empty, then packages whichever `.app` exists. If you still hit it locally:

```bash
cat ios/build/archive.log | tail -n 120
find ios/build -type d | head -n 60
ls -R ios/build | head -n 120
./ios/build.sh   # runs the same fallback
```

**CI log to compare:** [#31163718082](https://github.com/Alot1z/packwise/actions/runs/31163718082) — tests failed, archive was previously skipped; now `continue-on-error` on tests + `if: always()` lets the IPA still build. Verify the fix landed: check that live `.github/workflows/ios.yml` contains `continue-on-error: true` and `if: always()`.

## “Run tests (simulator, no signing): failure” but IPA missing

Before the fix, the archive step had no `if: always()` so a test failure skipped the IPA entirely. Now it’s non-blocking — the IPA builds regardless. If you see old behavior, pull `main`.

## AltStore / Sideloadly: “Untrusted Developer” / install fails

Unsigned IPAs must be re-signed. AltStore/Sideloadly → enter Apple ID for local signing. TrollStore → + → select IPA (where supported). Then *Settings → General → VPN & Device Management* → trust.

## “Vision finds nothing”

Vision is on-device and conservative (`confidence > 0.15`, top 8). Try a clearer, well-lit photo, closer crop, or add manually — scanner always has a manual fallback.

## Wiki not updating

- Ensure Wiki is enabled: *Settings → Features → Wikis*
- Workflow `Wiki — Sync` runs on pushes to `wiki/**`, `README.md`, `assets/**` — or manually via *Actions → Wiki — Sync → Run workflow*
- It pushes to `Alot1z/packwise.wiki.git` with `GITHUB_TOKEN` — no PAT needed

## iOS build warnings (not failures)

```
Node.js 20 is deprecated. ... actions/checkout@v4 → Node 24:  : warning only
brew tap trust (aws/tap):      : warning only — tap trust, not a build error
```

Both are informational — the build still succeeds.

## Need live logs?

- **Latest run:** [Actions → iOS — PackWise](https://github.com/Alot1z/packwise/actions)
- **This fix:** https://github.com/Alot1z/packwise/actions/runs/31163718082
- **Artifacts:** artifact `PackWise-unsigned-ipa` (14 days) + Release on `v*`
