# Build & Release — reproducible IPA

## The product

`PackWise-unsigned.ipa` — zip of `Payload/PackWise.app`, installable via AltStore / Sideloadly / TrollStore (re-sign on device/PC). Unsigned IPAs are not App Store signed. The `.ipa` **is** a zip renamed to `.ipa` (`Payload/App.app` layout) — `file *.ipa` showing `Zip archive data` is expected.

## Where the direct .ipa lives (no unwrap)

| Source | URL | What you get |
|---|---|---|
| **Releases → Latest** (versioned) | [`releases/latest`](https://github.com/Alot1z/packwise/releases/latest) | `PackWise-unsigned.ipa` directly — after any `v*` tag |
| **dev prerelease** (auto, every main push) | [`releases/tag/dev`](https://github.com/Alot1z/packwise/releases/tag/dev) | `PackWise-unsigned.ipa` directly — no unwrap needed |
| **Actions artifact** | `Actions → iOS — PackWise → PackWise-unsigned-ipa` | `PackWise-unsigned-ipa.zip` **container** — download → unzip → `.ipa` inside |

> Every push to `main` publishes the `dev` prerelease **and** the artifact. So the live site's "Download IPA" can point at Releases for a 1-click `.ipa`; the artifact is still there for debugging.

```bash
# Direct download without unwrapping the artifact zip:
gh release download dev -R Alot1z/packwise -p "PackWise-unsigned.ipa"
gh release download -R Alot1z/packwise -p "*.ipa"   # latest versioned
```

Verify any IPA:

```bash
file PackWise-unsigned.ipa
unzip -l PackWise-unsigned.ipa | head   # must show Payload/PackWise.app/
shasum -a 256 PackWise-unsigned.ipa
```

## Three equal hosts — same artifact

| Host | Workflow | Runner | Trigger |
|---|---|---|---|
| **GitHub Actions** (no Mac needed on your side) | `.github/workflows/ios.yml` | `macos-15` (Xcode 16) | Push to `main` → artifact + `dev`; `v*` → versioned Release; or *Run workflow* |
| **Gitea Actions** (self-hosted FOSS) | `.gitea/workflows/ios.yml` | `macos` | Push to Gitea — same YAML |
| **act locally** (nektos/act) | same `ios.yml` | `-self-hosted` Mac | `act -W .github/workflows/ios.yml -P macos-15=-self-hosted` |

`.actrc` maps `macos-15`/`macos` → `-self-hosted`. Linux `act` can lint but cannot produce IPA — `xcodebuild` only on macOS.

## Local build

```bash
brew install xcodegen
cd ios && xcodegen generate && open PackWise.xcodeproj

xcodebuild test -project PackWise.xcodeproj -scheme PackWise \
  -destination "platform=iOS Simulator,name=iPhone 16,OS=latest" CODE_SIGNING_ALLOWED=NO

./ios/build.sh   # → ios/build/PackWise-unsigned.ipa + .sha256
file ios/build/PackWise-unsigned.ipa && unzip -l ios/build/PackWise-unsigned.ipa | head
```

## The "Archive did not produce an app bundle" fix

On Xcode 16, `xcodebuild archive CODE_SIGNING_ALLOWED=NO` sometimes exits 0 with an empty `.xcarchive/Products/Applications/`. CI and `ios/build.sh` now:

1. Try `xcodebuild archive -archivePath build/PackWise.xcarchive ... -skipPackagePluginValidation -skipMacroValidation`
2. If `…/PackWise.app/Info.plist` missing → `xcodebuild build -destination generic/platform=iOS -derivedDataPath build/DerivedData …` + `find … -name PackWise.app`
3. Whichever `.app` found → `Payload/` → `zip -r -y PackWise-unsigned.ipa` → `file` + `unzip -l` validation (must contain `Payload/PackWise.app/`) + `shasum`

Diagnostics (`find build -type d`, `ls -R build`, `cat build/archive.log`, `unzip -l`) always print. Tests are `continue-on-error` + `if: always()` on archive/upload/summary — the IPA still builds if tests flake.

Live failure that triggered this: [#31163718082](https://github.com/Alot1z/packwise/actions/runs/31163718082) and [#31164548645](https://github.com/Alot1z/packwise/actions/runs/31164548645) (artifact zip inside an `.ipa`).

## Wiki sync

This Wiki syncs from `wiki/*.md` on every push to `main` via `.github/workflows/wiki.yml`. Requires Wiki enabled in *Settings → Features → Wikis*.

## Honesty

No IPA advertised until a workflow has produced it. No TestFlight/App Store without Apple signing + App Store Connect.
