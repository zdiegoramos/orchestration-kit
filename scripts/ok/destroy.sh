#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/common.sh"

NAME="${1:-}"

if [[ -z "$NAME" ]]; then
  echo "Usage: ok destroy <session-name>" >&2
  exit 1
fi

require_session "$NAME"

STATUS="$(get_state "$NAME" status)"
WORKTREE="$(get_state "$NAME" worktree)"
BRANCH="$(get_state "$NAME" branch)"

# Safety: confirm if session has uncommitted work
if [[ "$STATUS" == "executing" ]]; then
  PID="$(get_state "$NAME" pid)"
  if is_process_running "$PID" 2>/dev/null; then
    echo -e "${YELLOW}Stopping ralph loop...${NC}"
    bash "$(dirname "${BASH_SOURCE[0]}")/stop.sh" "$NAME"
  fi
fi

echo -e "${BOLD}Destroying session: ${RED}$NAME${NC}"
echo ""

# Switch away from the worktree if we're in it
CURRENT_DIR="$(pwd)"
if [[ "$CURRENT_DIR" == "$WORKTREE"* ]]; then
  cd "$REPO_ROOT"
fi

# Remove git worktree
if [[ -d "$WORKTREE" ]]; then
  echo -e "  Removing worktree..."
  git worktree remove "$WORKTREE" --force 2>/dev/null || {
    # Force remove if git complains
    rm -rf "$WORKTREE"
    git worktree prune 2>/dev/null || true
  }
fi

# Delete session branch (local only — remote branch stays for PRs)
if git show-ref --verify --quiet "refs/heads/$BRANCH" 2>/dev/null; then
  echo -e "  Deleting local branch ${CYAN}$BRANCH${NC}..."
  git branch -D "$BRANCH" 2>/dev/null || true
fi

# Remove session state
SDIR="$(session_dir "$NAME")"
if [[ -d "$SDIR" ]]; then
  echo -e "  Removing session state..."
  rm -rf "$SDIR"
fi

echo ""
echo -e "${GREEN}Session '$NAME' destroyed.${NC}"
