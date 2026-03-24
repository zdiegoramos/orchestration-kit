#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/common.sh"

NAME="${1:-}"

if [[ -z "$NAME" ]]; then
  echo "Usage: ok qa <session-name>" >&2
  exit 1
fi

require_session "$NAME"
refresh_session_status "$NAME"

STATUS="$(get_state "$NAME" status)"
WORKTREE="$(get_state "$NAME" worktree)"
BRANCH="$(get_state "$NAME" branch)"
BASE="$(get_state "$NAME" base_branch)"

# Stop execution if still running
if [[ "$STATUS" == "executing" ]]; then
  echo -e "${YELLOW}Stopping ralph loop for QA...${NC}"
  bash "$(dirname "${BASH_SOURCE[0]}")/stop.sh" "$NAME"
fi

set_state "$NAME" status "qa"

echo ""
echo -e "${BOLD}╔══════════════════════════════════════════════════╗${NC}"
echo -e "${BOLD}║     QA: ${BLUE}$NAME${NC}${BOLD}$(printf '%*s' $((40 - ${#NAME})) '')║${NC}"
echo -e "${BOLD}╚══════════════════════════════════════════════════╝${NC}"
echo ""

# Show diff summary
echo -e "${BOLD}Changes vs ${BASE}:${NC}"
echo ""
cd "$WORKTREE"

STAT=$(git diff "$BASE"..."$BRANCH" --stat 2>/dev/null || echo "(no changes)")
echo "$STAT"

COMMIT_COUNT=$(git rev-list --count "$BASE".."$BRANCH" 2>/dev/null || echo "0")
echo ""
echo -e "${BOLD}Commits:${NC} $COMMIT_COUNT"
echo ""

# Show ralph commits
echo -e "${BOLD}RALPH commits:${NC}"
git log "$BASE".."$BRANCH" --oneline --grep="RALPH" 2>/dev/null || echo "  (none)"
echo ""

echo -e "${DIM}──────────────────────────────────────────────────${NC}"
echo ""
echo -e "  Worktree: ${CYAN}$WORKTREE${NC}"
echo ""
echo -e "  Review the changes, then:"
echo -e "    ${BOLD}ok approve $NAME${NC}   — create PR and merge"
echo -e "    ${BOLD}ok start $NAME${NC}     — continue execution"
echo -e "    ${BOLD}ok destroy $NAME${NC}   — discard changes"
echo ""
