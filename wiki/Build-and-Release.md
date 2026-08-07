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

Verify any download (`.ipa`, artifact `.zip`, or folder — one command):

```bash
./scripts/verify-ipa.sh <downloaded-file>
```

Or manually:

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

## The "missing executable" fix — self-healing cascade

On Xcode 16, `CODE_SIGNING_ALLOWED=NO` can exit 0 while emitting an app bundle **without the main executable** (or with test bundles injected). We confirmed this by downloading the old `dev` build and inspecting it: it contained `PlugIns/PackWiseTests.xctest`, a dozen XCTest frameworks, and **no `Payload/PackWise.app/PackWise` binary at all** — that is literally the `Failed to map …/PackWise: Bad file descriptor` sideload failure.

`ios/build.sh` (used by both CI workflows) is now self-healing — it tries, in order:

1. **A · `xcodebuild build -sdk iphoneos`** (device arm64, isolated `DerivedData`)
2. **B · `xcodebuild archive`** (classic product path)
3. **C · legacy build** (no `-destination`)

Each candidate `.app` must pass validation before it is used: the executable must exist, be non-empty, be arm64 Mach-O, and carry `LC_BUILD_VERSION platform 2` (never `7` = simulator — simulator binaries cannot sideload). The winning bundle is staged to `Payload/`, test injection is stripped (`PlugIns`, `_CodeSignature`, `*.xctest`, `XCTest`/`XCUnit`/`XCUIAutomation`/`XCTAutomationSupport`/`Testing.framework`, `libXCTest*`), and the final `.ipa` must pass a strict publish gate:

- `unzip -t` integrity passes
- contains `Payload/PackWise.app/PackWise` **and** `Info.plist`
- contains **no** test/signing artifacts — otherwise the job fails loudly

Full diagnostics (`tail build/build.log`, `find`, `ls`) are written to `ios/build/diagnostics.txt` and uploaded as the **`ios-build-diagnostics`** artifact on every run (`if: always()`) — so any future failure is publicly readable without sign-in, and the job summary shows the last 60 lines on failure.

Live failures that triggered this: [#31163718082](https://github.com/Alot1z/packwise/actions/runs/31163718082) (tests blocked the old archive step), [#31164548645](https://github.com/Alot1z/packwise/actions/runs/31164548645) (artifact zip vs direct `.ipa`), and the 2026-08-07 `dev` build inspection (missing executable + test injection).

## Wiki sync

This Wiki syncs from `wiki/*.md` on every push to `main` via `.github/workflows/wiki.yml`. Requires Wiki enabled in *Settings → Features → Wikis*.

## Honesty

No IPA advertised until a workflow has produced it. No TestFlight/App Store without Apple signing + App Store Connect.
