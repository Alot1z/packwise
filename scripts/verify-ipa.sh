#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────────────────────
# PackWise — verify-ipa.sh
#
# One command that tells you whether ANY PackWise download is sideload-ready,
# before you waste ten minutes on a sideloader error.
#
#   ./scripts/verify-ipa.sh <file-or-directory>
#
# Accepts:
#   • the direct  .ipa            from GitHub Releases / Gitea Releases
#   • the .zip    GitHub Actions artifact  (auto-unwraps the inner .ipa)
#   • any folder containing a .ipa or a Payload/ directory
#
# Checks (same rules as the CI publish gate):
#   • zip integrity
#   • Payload/<App>.app exists
#   • the main executable exists, is non-empty, and is arm64 device Mach-O
#   • no test bundles, no signing artifacts
#   • prints sha256 so you can compare against the Release .sha256
#
# Exit codes:  0 = sideload-ready · 1 = invalid · 2 = not a PackWise artifact
#              64 = usage
# ─────────────────────────────────────────────────────────────────────────────
set -euo pipefail

INPUT="${1:-}"
if [ -z "$INPUT" ]; then
  echo "usage: $0 <PackWise-*.ipa | artifact.zip | folder>" >&2
  exit 64
fi

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

say()  { printf '%s\n' "$*"; }
pass() { printf '✓  %s\n' "$*"; }
warn() { printf '⚠  %s\n' "$*" >&2; }
fail() { printf '✗  %s\n' "$*" >&2; exit 1; }

# ── 1 · locate the actual .ipa (unwrap GitHub artifact zips / folders) ──────
IPA=""
if [ -d "$INPUT" ]; then
  hit=$(find "$INPUT" -maxdepth 3 -name "*.ipa" 2>/dev/null | head -n 1)
  if [ -n "$hit" ]; then IPA="$hit"; say "→ found .ipa inside folder: $hit"
  elif [ -d "$INPUT/Payload" ]; then IPA="$INPUT"; say "→ found Payload/ folder (an unzipped .ipa)"
  else fail "'$INPUT' is a folder with no .ipa or Payload/ inside — nothing to verify."; fi
else
  IPA="$INPUT"
fi

[ -f "$IPA" ] || fail "file not found: $IPA"

# ZIP or plain? Everything PackWise ships is a zip (an .ipa IS a zip).
case "$(unzip -Z1 "$IPA" 2>/dev/null | head -n 1)" in
  *.ipa)  # GitHub Actions artifact wrapper: <name>.zip → inner <name>.ipa
          warn "GitHub artifact detected (outer .zip wrapper)."
          warn "Direct downloads avoid this: github.com/Alot1z/packwise/releases/tag/dev"
          INNER=$(unzip -Z1 "$IPA" 2>/dev/null | grep -m1 '\.ipa$' || true)
          [ -n "$INNER" ] || fail "artifact zip contains no .ipa"
          unzip -oq "$IPA" "$INNER" -d "$TMP" || fail "could not unwrap artifact zip"
          IPA="$TMP/$INNER"
          say "→ unwrapped to ${IPA##*/}"
          ;;
  Payload/*) : ;;  # already an .ipa structure — verify as-is
  "") fail "'$IPA' is not a zip and not an .ipa — did you download the wrong asset?" ;;
  *)  # a zip that is neither artifact wrapper nor Payload layout
      fail "'$IPA' is a zip but has no Payload/ and no .ipa inside — not a PackWise build." ;;
esac

say ""
say "Verifying: $IPA ($(du -h "$IPA" | cut -f1))"

# ── 2 · zip integrity ───────────────────────────────────────────────────────
unzip -tq "$IPA" >/dev/null 2>&1 || fail "zip integrity check failed — download may be truncated. Re-download it."
pass "zip integrity"

# ── 3 · Payload/<App>.app present ───────────────────────────────────────────
APP_DIR=$(unzip -Z1 "$IPA" 2>/dev/null | grep -m1 -oE 'Payload/[^/]+\.app' || true)
[ -n "$APP_DIR" ] || fail "no Payload/<App>.app found — this is not a valid iOS app bundle."
APP_NAME="${APP_DIR##*/}"                 # PackWise.app
APP_ID="${APP_NAME%.app}"                 # PackWise
pass "bundle: $APP_DIR"

# ── 4 · main executable present & sane ──────────────────────────────────────
# Prefer the Info.plist's declared CFBundleExecutable; fall back to the app name.
EXEC_NAME="$APP_ID"
PLIST_XML=$(unzip -p "$IPA" "$APP_DIR/Info.plist" 2>/dev/null || true)
if command -v python3 >/dev/null 2>&1; then
  EXEC_NAME=$(printf '%s' "$PLIST_XML" | python3 -c "
import plistlib, sys
try:
    print(plistlib.loads(sys.stdin.buffer.read()).get('CFBundleExecutable',''))
except Exception:
    print('')
" 2>/dev/null) && [ -n "$EXEC_NAME" ] || EXEC_NAME="$APP_ID"
fi
[ -n "$EXEC_NAME" ] || EXEC_NAME="$APP_ID"

EXEC_PATH="$APP_DIR/$EXEC_NAME"
unzip -Z1 "$IPA" 2>/dev/null | grep -q "^${EXEC_PATH}$" || \
  fail "main executable missing: $EXEC_PATH — this is the 'Failed to map …/PackWise: Bad file descriptor' failure. Use the latest build."

# The executable entry must be a regular file. Sideloaders mmap the binary;
# a symlink inside the .app cannot be mapped and fails with exactly
# "Failed to map …/PackWise: Bad file descriptor" (EBADF). Detect it from
# the zip's own metadata (Unix attrs) — no host tools required.
if unzip -Z -v "$IPA" "$EXEC_PATH" 2>/dev/null | grep -q 'lrwxrwxrwx'; then
  fail "main executable is a symlink inside the zip (Unix attrs lrwxrwxrwx) — sideloaders cannot map it ('Failed to map …/PackWise: Bad file descriptor'). This build is broken; use the latest CI build."
fi

# Extract just the executable for binary inspection.
unzip -oq "$IPA" "$EXEC_PATH" -d "$TMP" || fail "could not extract $EXEC_PATH"
EXEC_FILE="$TMP/$EXEC_PATH"
[ -s "$EXEC_FILE" ] || fail "$EXEC_PATH exists in the zip but is empty or unreadable — sideloaders cannot map it ('Failed to map …/PackWise: Bad file descriptor'). This build is broken; use the latest CI build."

if command -v file >/dev/null 2>&1; then
  KIND=$(file "$EXEC_FILE")
  case "$KIND" in
    *arm64*) pass "executable: arm64 device Mach-O" ;;
    *x86_64*) fail "executable is x86_64 (simulator) — cannot sideload on a device. Use the CI build." ;;
    *) warn "unexpected binary type: $KIND" ;;
  esac
fi
if command -v otool >/dev/null 2>&1; then
  PLAT=$(otool -l "$EXEC_FILE" 2>/dev/null | grep -A5 "LC_BUILD_VERSION" | grep -m1 "platform" | awk '{print $2}' || true)
  [ "$PLAT" = "2" ] && pass "platform: iOS device (LC_BUILD_VERSION=2)"
  [ "$PLAT" = "7" ] && fail "platform: simulator — cannot sideload. Use the CI build."
fi

# ── 4b · Dependency-free Mach-O probe — inspects the binary itself, so the
#        “Bad file descriptor” question (is it a real device executable?) is
#        answered even on machines without `file`/`otool` (e.g. Linux). ──
if command -v python3 >/dev/null 2>&1; then
  PROBE=$(unzip -p "$IPA" "$EXEC_PATH" 2>/dev/null | python3 -c '
import sys, struct
d = sys.stdin.buffer.read()
if len(d) < 12:
    print("NOTMACHO:too-small")
    sys.exit(0)
m = d[:4]
def cpu(t, st):
    if t == 0x0100000C: return "arm64e" if st == 2 else "arm64"
    if t == 0x01000007: return "x86_64"
    if t == 0x00000007: return "i386"
    if t == 0x0000000C: return "arm"
    return "cpu-%x" % t
# On disk, magic is byte-order-dependent: 0xfeedfacf little-endian = cf fa ed fe.
if m in (b"\xca\xfe\xba\xbe", b"\xbe\xba\xfe\xca"):
    e = "<" if m == b"\xbe\xba\xfe\xca" else ">"   # fat headers are big-endian
    n = struct.unpack(e + "I", d[4:8])[0]
    s, off = [], 8
    for _ in range(n):
        if off + 20 > len(d): break
        t, st = struct.unpack(e + "II", d[off:off+8]); off += 20
        s.append(cpu(t, st))
    print("FAT[" + ",".join(s) + "]")
elif m in (b"\xcf\xfa\xed\xfe", b"\xfe\xed\xfa\xcf"):
    e = "<" if m == b"\xcf\xfa\xed\xfe" else ">"   # 0xfeedfacf LE on disk for arm64/x86_64
    t, st = struct.unpack(e + "II", d[4:12])
    print(cpu(t, st))
elif m in (b"\xce\xfa\xed\xfe", b"\xfe\xed\xfa\xce"):
    print("NOTMACHO:32-bit-legacy")
else:
    print("NOTMACHO:unknown-magic")
')
  case "$PROBE" in
    arm64|arm64e) pass "executable: Mach-O $PROBE (device)" ;;
    x86_64|i386|arm) fail "executable is a $PROBE binary (simulator/legacy) — cannot sideload on a device. Use the CI build." ;;
    FAT*)
      if printf '%s' "$PROBE" | grep -qE 'x86_64|i386'; then
        fail "fat binary contains a simulator slice: ${PROBE#FAT} — cannot sideload on a device. Use the CI build."
      else
        pass "executable: fat Mach-O ${PROBE#FAT}"
      fi ;;
    NOTMACHO:*)
      fail "executable is not a valid Mach-O binary (${PROBE#NOTMACHO:}) — sideloaders cannot map it ('Failed to map …/PackWise: Bad file descriptor'). Use the latest CI build." ;;
    *) warn "unexpected Mach-O probe: '$PROBE'" ;;
  esac
fi
pass "executable present: $EXEC_PATH"

# ── 5 · no test bundles / signing leftovers ─────────────────────────────────
if unzip -Z1 "$IPA" 2>/dev/null | grep -qE '\.xctest|XCTest|XCUnit|XCUIAutomation|XCTAutomationSupport|XCTestSupport|Testing\.framework|libXCTest|libTesting|_CodeSignature|PlugIns/'; then
  fail "bundle still contains test/signing artifacts — this build must not be sideloaded."
fi
pass "no test bundles, no signing leftovers (unsigned — expected)"

# ── 6 · hash + verdict ──────────────────────────────────────────────────────
HASH=$(shasum -a 256 "$IPA" 2>/dev/null | awk '{print $1}' || sha256sum "$IPA" | awk '{print $1}')
say ""
say "──────────────────────────────────────────────────────────────"
pass "sideload-ready: $IPA"
say "  sha256: $HASH"
say ""
say "Next steps:"
say "  1. Compare the sha256 above with the .sha256 file in the Release."
say "  2. Transfer the .ipa to your iPhone (AirDrop / Files / computer)."
say "  3. Open it in AltStore, Sideloadly, or TrollStore — they re-sign locally."
say "  4. If the sideloader still complains, download the latest build:"
say "     gh release download dev -R Alot1z/packwise -p 'PackWise-unsigned.ipa'"
say "──────────────────────────────────────────────────────────────"
