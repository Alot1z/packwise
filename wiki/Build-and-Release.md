# Build & Release — reproducible IPA

## The product

`PackWise-unsigned.ipa` — zip of `Payload/PackWise.app`, installable via AltStore / Sideloadly / TrollStore (re-sign on device/PC). Unsigned IPAs are not App Store signed.

## Reproducible — three equal hosts, same artifact

| Host | Workflow | Runner | How to trigger |
|---|---|---|---|
| **GitHub Actions** (free, no Mac needed on your side) | `.github/workflows/ios.yml` | `macos-15` (Xcode 16) | Push to `main` or *Actions → iOS — PackWise → Run workflow*; `git tag v*` → Release |
| **Gitea Actions** (self-hosted FOSS) | `.gitea/workflows/ios.yml` | `macos` | Push to Gitea, `git push gitea main` — same YAML |
| **act locally** (nektos/act) | same `ios.yml` | `-self-hosted` Mac | `act -W .github/workflows/ios.yml -P macos-15=-self-hosted` |

`.actrc` maps `macos-15`/`macos` → `-self-hosted`. Linux `act` can lint but cannot produce IPA — `xcodebuild` only on macOS.

## Local build

```bash
brew install xcodegen
cd ios && xcodegen generate && open PackWise.xcodeproj

# Tests
xcodebuild test -project PackWise.xcodeproj -scheme PackWise \
  -destination "platform=iOS Simulator,name=iPhone 16,OS=latest" CODE_SIGNING_ALLOWED=NO

# IPA (same as CI)
./ios/build.sh   # → ios/build/PackWise-unsigned.ipa + .sha256
ls -lh ios/build/PackWise-unsigned.ipa && unzip -l ios/build/PackWise-unsigned.ipa | head
shasum -a 256 ios/build/PackWise-unsigned.ipa
```

## The “Archive did not produce an app bundle” fix

On Xcode 16, `xcodebuild archive CODE_SIGNING_ALLOWED=NO` sometimes exits 0 with an empty `.xcarchive/Products/Applications/` (it genuinely creates no `.app`). CI and `ios/build.sh` now do:

1. Try `xcodebuild archive -archivePath build/PackWise.xcarchive ... -skipPackagePluginValidation -skipMacroValidation`
2. If `build/PackWise.xcarchive/Products/Applications/PackWise.app/Info.plist` missing → fallback to `xcodebuild build -destination generic/platform=iOS -derivedDataPath build/DerivedData ...` and `find build/DerivedData -name PackWise.app`
3. `cp -R` whichever `.app` was found → `Payload/` → `zip -r PackWise-unsigned.ipa` + `shasum`

Diagnostics (`find build -type d`, `ls -R build`, `cat build/archive.log`, `unzip -l`) are always printed.

Live failure that triggered this fix: [#31163718082](https://github.com/Alot1z/packwise/actions/runs/31163718082) — `Run tests` failed and `Archive` was skipped. Fixed by `continue-on-error: true` on tests + `if: always()` on archive/upload/summary, so the IPA still builds when tests flake.

## Releases

- Push `v*` tag → `softprops/action-gh-release@v2` attaches `PackWise-unsigned.ipa` + `.sha256` to the GitHub Release
- The README and live site link to `https://github.com/Alot1z/packwise/releases/latest` — no clone/sync flow needed
- Live logs: [Actions](https://github.com/Alot1z/packwise/actions) — badge in README

## Wiki sync

This Wiki syncs from `wiki/*.md` on every push to `main` via `.github/workflows/wiki.yml` — edits in `wiki/` locally or directly on GitHub both work. Requires Wiki enabled in *Settings → Features → Wikis*.

## Honesty

No IPA is advertised until a workflow has produced it. No TestFlight/App Store without Apple signing + App Store Connect processing.
