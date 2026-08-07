#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────────────────────
# PackWise — release-manifest.sh
#
# Generates (or updates) a machine-readable manifest of all PackWise releases.
# The output (`PackWise-releases.json`) is attached as a release asset on every
# published build so an algorithm — or an AI — can fetch ONE URL to discover:
#
#   · the newest *stable* release      (manifest.latest)
#   · the newest *dev* prerelease     (manifest.dev)
#   · recent release history with sha256s (manifest.releases[])
#
# Deterministic URLs an algorithm can use (no GitHub API key required):
#   https://github.com/Alot1z/packwise/releases/latest/download/PackWise-releases.json
#   https://github.com/Alot1z/packwise/releases/download/dev/PackWise-releases.json
#   https://github.com/Alot1z/packwise/releases/download/vX.Y.Z/PackWise-releases.json
#
# Usage:
#   release-manifest.sh --tag <vX.Y.Z|dev> --ipa <path> \
#                       --output <manifest.json> \
#                       [--repo owner/repo] [--prerelease] \
#                       [--sha256 <hash>] [--prior <manifest.json>] [--keep 12] \
#                       [--published-at <ISO-8601 UTC>]
#
# Exit codes: 0 ok · 1 invalid · 64 usage
# ─────────────────────────────────────────────────────────────────────────────
set -euo pipefail

usage() {
  cat >&2 <<'EOF'
Usage: release-manifest.sh --tag <vX.Y.Z|dev> --ipa <path> \
                           --output <manifest.json> \
                           [--repo owner/repo] [--prerelease] \
                           [--sha256 <hash>] [--prior <manifest.json>] \
                           [--keep 12] [--published-at ISO8601]
EOF
  exit 64
}

TAG=""; IPA=""; OUT=""; REPO="${REPO_DEFAULT:-Alot1z/packwise}"
SHA=""; IS_PRE="false"; PRIOR=""; KEEP="12"; PUB_AT=""
while [ $# -gt 0 ]; do
  case "$1" in
    --tag)        TAG="$2"; shift 2;;
    --ipa)        IPA="$2"; shift 2;;
    --sha256)     SHA="$2"; shift 2;;
    --output)     OUT="$2"; shift 2;;
    --repo)       REPO="$2"; shift 2;;
    --prerelease) IS_PRE="true"; shift;;
    --prior)      PRIOR="$2"; shift 2;;
    --keep)       KEEP="$2"; shift 2;;
    --published-at) PUB_AT="$2"; shift 2;;
    -h|--help)    usage;;
    *)            echo "unknown arg: $1" >&2; usage;;
  esac
done
[ -n "$TAG" ] || { echo "missing --tag" >&2; usage; }
[ -n "$IPA" ] || { echo "missing --ipa" >&2; usage; }
[ -n "$OUT" ] || { echo "missing --output" >&2; usage; }
[ -f "$IPA" ] || { echo "ipa not found: $IPA" >&2; exit 1; }

# ── Resolve shasum if not provided ───────────────────────────────────────────
if [ -z "$SHA" ]; then
  cand="$(dirname "$IPA")/$(basename "$IPA" .ipa).sha256"
  if [ -f "$cand" ]; then
    SHA=$(awk '{print $1; exit}' "$cand")
  elif [ -f "$IPA.sha256" ]; then
    SHA=$(awk '{print $1; exit}' "$IPA.sha256")
  elif command -v shasum >/dev/null 2>&1; then
    SHA=$(shasum -a 256 "$IPA" | awk '{print $1}')
  elif command -v sha256sum >/dev/null 2>&1; then
    SHA=$(sha256sum "$IPA" | awk '{print $1}')
  fi
fi
[ -n "$SHA" ] || { echo "could not determine sha256 of $IPA — pass --sha256" >&2; exit 1; }

# ── File size (cross-platform stat) ──────────────────────────────────────────
if   command -v stat >/dev/null 2>&1 && stat -c '%s' /dev/null >/dev/null 2>&1; then
  SIZE=$(stat -c '%s' "$IPA")
elif command -v stat >/dev/null 2>&1; then
  SIZE=$(stat -f '%z' "$IPA")
else
  SIZE=$(wc -c <"$IPA" | tr -d ' ')
fi

# ── Published-at (UTC) ───────────────────────────────────────────────────────
if [ -z "$PUB_AT" ]; then
  PUB_AT=$(date -u +%Y-%m-%dT%H:%M:%SZ 2>/dev/null || python3 -c "import datetime;print(datetime.datetime.utcnow().strftime('%Y-%m-%dT%H:%M:%SZ'))")
fi

# ── Compute output via python (guarantees valid JSON) ─────────────────────────
IS_PRE_FLAG="$IS_PRE" PUB="$PUB_AT" KEEP_N="$KEEP" python3 - <<'PY' "$TAG" "$IPA" "$OUT" "$REPO" "$SHA" "$PRIOR" "$SIZE"
import json, os, sys, datetime
(tag, ipa, out_path, repo, sha, prior, size) = sys.argv[1:]
is_pre = os.environ["IS_PRE_FLAG"] == "true"
keep   = int(os.environ["KEEP_N"])
pub    = os.environ["PUB"]
size_i = int(size)

release_url = f"https://github.com/{repo}/releases/tag/{tag}"
asset_url   = f"https://github.com/{repo}/releases/download/{tag}/PackWise-unsigned.ipa"

entry = {
    "tag": tag,
    "name": ("PackWise — release (dev prerelease)" if tag == "dev"
             else ("PackWise — release (prerelease)" if is_pre
                   else "PackWise — release")),
    "prerelease":   is_pre,
    "is_dev":       tag == "dev",
    "is_latest":    False,           # resolver sets this
    "release_url":  release_url,
    "asset_url":    asset_url,
    "ipa_filename": "PackWise-unsigned.ipa",
    "sha256":       sha,
    "size_bytes":   size_i,
    "published_at": pub,
    "verify_command": f"shasum -a 256 PackWise-unsigned.ipa   # expect {sha}",
}

prev = {"releases": []}
if prior and os.path.exists(prior):
    try:
        with open(prior) as f: prev = json.load(f)
        prev.setdefault("releases", [])
    except Exception:
        prev = {"releases": []}

# Replace any prior entry with same tag (idempotent re-publish), prepend new.
merged = [r for r in prev["releases"] if r.get("tag") != tag]
merged.insert(0, entry)
# Sort newest first; tiebreak by tag desc for determinism.
merged.sort(key=lambda r: (r.get("published_at",""), r.get("tag","")), reverse=True)
trimmed = merged[:keep]

# Resolve latest = newest non-prerelease; fall back to newest overall.
latest = next((r for r in trimmed if not r.get("prerelease", False)), None) or (trimmed[0] if trimmed else None)
for r in trimmed: r["is_latest"] = (latest is not None and r is latest)

dev_entry = next((r for r in trimmed if r.get("is_dev")), None)

def pointer(r):
    return {
        "tag":          r["tag"],
        "release_url":  r["release_url"],
        "asset_url":    r["asset_url"],
        "sha256":       r["sha256"],
        "prerelease":   r.get("prerelease", False),
        "is_dev":       r.get("is_dev", False),
        "size_bytes":   r.get("size_bytes"),
        "published_at": r.get("published_at"),
    } if r else None

manifest = {
    "schema":      "packwise.releases/v1",
    "repository":  repo,
    "homepage":    f"https://github.com/{repo}",
    "ipa_filename": "PackWise-unsigned.ipa",
    "generated_at": pub,
    "how_to_find_newest": {
        "stable": "manifest.latest",
        "dev":    "manifest.dev",
        "history": "manifest.releases (sorted newest-first, is_latest flagged)",
        "verify":  "compare assets[*].sha256 with manifest.latest.sha256"
    },
    "latest":   pointer(latest),
    "dev":      pointer(dev_entry),
    "releases": trimmed,
}

with open(out_path, "w") as f:
    json.dump(manifest, f, indent=2, sort_keys=False)
    f.write("\n")

n = len(trimmed)
print(f"wrote {out_path}: {n} release(s); "
      f"latest={'none' if manifest['latest'] is None else manifest['latest']['tag']}; "
      f"dev={'none' if manifest['dev'] is None else manifest['dev']['tag']}")
PY
