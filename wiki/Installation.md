# Installation — 3 steps, no tech needed

> The IPA is **unsigned** — your sideload tool re-signs it on install. Normal for open-source iOS apps.

## 1 · Download

- **[Releases → Latest](https://github.com/Alot1z/packwise/releases/latest)** → `PackWise-unsigned.ipa` (+ `.sha256`)
- Or any green run: **Actions → iOS — PackWise → artifact `PackWise-unsigned-ipa`**

No Releases yet? Push to `main` or *Actions → Run workflow* — first IPA appears as artifact, then as Release on `git tag v*`.

## 2 · Sideload — pick one

**AltStore** — Install AltServer on Mac/PC → connect iPhone → AltStore → *My Apps* → **+** → select the IPA.

**Sideloadly** — Drag IPA onto Sideloadly → Apple ID for local signing → Start.

**TrollStore** (supported versions) — Open TrollStore → **+** → select IPA — no re-sign.

## 3 · Trust & open

*Settings → General → VPN & Device Management* → trust the developer → open PackWise.

## Verify

```bash
unzip -l PackWise-unsigned.ipa | head   # should show Payload/PackWise.app/
shasum -a 256 PackWise-unsigned.ipa     # compare to .sha256
```

## Screenshots

Place real device captures at `ios/screenshots/1.png` etc. — the README and live site show placeholders until you add them.
