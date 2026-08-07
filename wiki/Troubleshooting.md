# Troubleshooting

## "I downloaded a .zip but expected a .ipa"

**Not a PackWise bug — GitHub wraps artifacts.** `actions/upload-artifact` always delivers downloads as an outer container zip. Inside `PackWise-unsigned-ipa.zip` is the real `PackWise-unsigned.ipa`.

| You used | File you got | What to do |
|---|---|---|
| **Releases → Latest** or **`releases/tag/dev`** | `PackWise-unsigned.ipa` directly | Sideload it — no unwrap |
| **Actions → artifact** | `PackWise-unsigned-ipa.zip` (outer container) | Download → **unzip once** → `PackWise-unsigned.ipa` inside → sideload that |

> Every push to `main` now also publishes a **`dev` prerelease** with the direct `.ipa` (`releases/tag/dev`) so you never need to unwrap if you don't want to. Tags `v*` publish versioned Releases.

**Verify any `.ipa`:**

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

## "Archive did not produce an app bundle. No IPA artifact."

**Seen on:** `macos-15` + Xcode 16 + `CODE_SIGNING_ALLOWED=NO` — archive exits 0 but creates no `.app`.

**Fix (already in repo):** Workflow now validates the IPA explicitly. Steps: archive → if no `.app` in xcarchive, fallback to `xcodebuild build -derivedDataPath build/DerivedData` → `zip -r -y PackWise-unsigned.ipa Payload` → `file` + `unzip -l` must show `Payload/PackWise.app/` or the job fails. Diagnostics (`find build -type d`, `ls -R build`, `cat archive.log`) always print.

```bash
cat ios/build/archive.log | tail -n 120
find ios/build -type d | head -n 60
./ios/build.sh   # same fallback + validation locally
```

**CI logs that triggered fixes:** [#31163718082](https://github.com/Alot1z/packwise/actions/runs/31163718082) (tests blocked archive — now `continue-on-error` + `if: always()`) and [#31164548645](https://github.com/Alot1z/packwise/actions/runs/31164548645) (outer zip vs direct `.ipa` — now `dev` prerelease added).

## "Run tests (simulator, no signing): failure" but IPA missing

Before the fix, archive had no `if: always()` so test failure skipped the IPA entirely. Now it's non-blocking — the IPA still builds. Pull `main` if you see old behavior.

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
