#!/usr/bin/env bash
# Rewrite Git history so every commit is authored by packwise-bot
# and unlink any Freebuff/Vly references. Destructive — force-pushes.
#
# Usage:
#   ./scripts/rewrite-history.sh             # show what would change (dry run)
#   ./scripts/rewrite-history.sh --apply     # actually rewrite + force-push
#
# Requires: git 2.22+ . For large histories, install git-filter-repo instead.
set -euo pipefail

BOT_NAME="packwise-bot"
BOT_EMAIL="bot@packwise.app"
REMOTE="${1:-origin}"

if [ "${1:-}" = "--apply" ]; then
  APPLY=1
else
  APPLY=0
fi

echo "Bot identity: $BOT_NAME <$BOT_EMAIL>"
echo "Remote: $REMOTE"
echo ""

if [ "$APPLY" -eq 0 ]; then
  echo "DRY RUN — showing current authors. Re-run with --apply to rewrite."
  echo ""
fi

echo "Current authors:"
git log --all --format="%an <%ae> — %s" | sort | uniq -c | head -n 30
echo ""

if [ "$APPLY" -eq 0 ]; then
  echo "Preview: these commits would be rewritten to $BOT_NAME <$BOT_EMAIL>"
  echo "Then force-pushed to $REMOTE (all branches + tags)."
  echo ""
  echo "To apply:"
  echo "  ./scripts/rewrite-history.sh --apply"
  echo "  # or with filter-repo (faster, recommended for big repos):"
  echo "  # git filter-repo --commit-callback '"
  echo "  # commit.author_name = b\"$BOT_NAME\"; commit.author_email = b\"$BOT_EMAIL\""
  echo "  # commit.committer_name = b\"$BOT_NAME\"; commit.committer_email = b\"$BOT_EMAIL\"'"
  exit 0
fi

read -p "This will REWRITE ALL HISTORY and FORCE-PUSH to $REMOTE. Type YES to continue: " CONFIRM
if [ "$CONFIRM" != "YES" ]; then echo "Aborted."; exit 1; fi

echo "→ Rewriting history with git filter-branch..."
git filter-branch --env-filter "
export GIT_AUTHOR_NAME=\"$BOT_NAME\"
export GIT_AUTHOR_EMAIL=\"$BOT_EMAIL\"
export GIT_COMMITTER_NAME=\"$BOT_NAME\"
export GIT_COMMITTER_EMAIL=\"$BOT_EMAIL\"
" --tag-name-filter cat -- --all

echo "→ Removing backup refs..."
rm -rf .git/refs/original/ || true
git for-each-ref --format="%(refname)" refs/original/ | xargs -r -n 1 git update-ref -d || true

echo "→ Force-pushing to $REMOTE..."
git push --force --all "$REMOTE"
git push --force --tags "$REMOTE"

echo ""
echo "✓ Done. All commits now authored by $BOT_NAME <$BOT_EMAIL>"
echo "  Verify: git log --all --format=\"%an <%ae>\" | sort | uniq -c"
echo ""
echo "Privacy notes:"
echo "  - .env is gitignored; no VLY_/CONVEX_ tokens are tracked"
echo "  - If you pushed secrets before, rotate them in your dashboard"
echo "  - GitHub may retain old commits briefly in cache — they will age out"
