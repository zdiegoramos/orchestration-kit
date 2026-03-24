#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/common.sh"

NAME="${1:-}"

if [[ -z "$NAME" ]]; then
  echo "Usage: ok approve <session-name>" >&2
  exit 1
fi

require_session "$NAME"
refresh_session_status "$NAME"

STATUS="$(get_state "$NAME" status)"
WORKTREE="$(get_state "$NAME" worktree)"
BRANCH="$(get_state "$NAME" branch)"
BASE="$(get_state "$NAME" base_branch)"

# Must be in qa, complete, or stopped state
case "$STATUS" in
  qa|complete|stopped) ;;
  executing)
    echo "Session is still executing. Run 'ok qa $NAME' first to review." >&2
    exit 1
    ;;
  merged)
    echo "Session '$NAME' is already merged." >&2
    exit 0
    ;;
  *)
    echo "Session '$NAME' is in status '$STATUS' — cannot approve." >&2
    exit 1
    ;;
esac

# Stop execution if somehow still running
PID="$(get_state "$NAME" pid)"
if is_process_running "$PID" 2>/dev/null; then
  echo -e "${YELLOW}Stopping ralph loop...${NC}"
  bash "$(dirname "${BASH_SOURCE[0]}")/stop.sh" "$NAME"
fi

set_state "$NAME" status "approved"

echo ""
echo -e "${BOLD}Approving session: ${CYAN}$NAME${NC}"
echo ""

cd "$WORKTREE"

# Push session branch
echo -e "Pushing branch ${CYAN}$BRANCH${NC}..."
git push -u origin "$BRANCH" 2>/dev/null || {
  echo -e "${YELLOW}Could not push branch. Creating PR from local branch.${NC}"
}

# Create PR
echo -e "Creating pull request..."

COMMIT_COUNT=$(git rev-list --count "$BASE".."$BRANCH" 2>/dev/null || echo "0")
STAT=$(git diff "$BASE"..."$BRANCH" --stat 2>/dev/null || echo "")

PR_BODY="## Session: $NAME

Automated session created via \`ok\`.

### Summary
- **Branch:** \`$BRANCH\`
- **Base:** \`$BASE\`
- **Commits:** $COMMIT_COUNT

### Changes
\`\`\`
$STAT
\`\`\`
"

PR_URL=$(gh pr create \
  --base "$BASE" \
  --head "$BRANCH" \
  --title "Session: $NAME" \
  --body "$PR_BODY" \
  2>/dev/null) || {
    echo -e "${YELLOW}PR creation failed. You can create it manually:${NC}"
    echo "  gh pr create --base $BASE --head $BRANCH"
    exit 1
  }

echo ""
echo -e "${GREEN}╔══════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║  PR created!                                     ║${NC}"
echo -e "${GREEN}╚══════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "  ${BOLD}PR:${NC} $PR_URL"
echo ""
echo -e "  To merge now:     ${BOLD}gh pr merge $PR_URL --squash${NC}"
echo -e "  To clean up:      ${BOLD}ok destroy $NAME${NC}"
echo ""

set_state "$NAME" status "approved"
