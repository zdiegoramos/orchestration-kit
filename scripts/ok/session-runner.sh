#!/usr/bin/env bash
set -eo pipefail

# Internal script: runs the ralph loop for a session in the background.
# Invoked by start.sh via nohup. Not user-facing.
#
# Usage: session-runner.sh <session-name> <max-iterations>

source "$(dirname "${BASH_SOURCE[0]}")/common.sh"

NAME="$1"
MAX_ITERATIONS="${2:-20}"

require_session "$NAME"

WORKTREE="$(get_state "$NAME" worktree)"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

cd "$WORKTREE"

# Use the ralph prompt and context from the worktree
RALPH_PROMPT="$WORKTREE/scripts/ralph-prompt.md"
if [[ ! -f "$RALPH_PROMPT" ]]; then
  # Fall back to the main repo's prompt
  RALPH_PROMPT="$REPO_ROOT/scripts/ralph-prompt.md"
fi

RALPH_CONTEXT_FILES=${RALPH_CONTEXT_FILES:-"@plans/prd.md @plans/tasks.md @progress.txt"}

for ((i=1; i<=MAX_ITERATIONS; i++)); do
  echo ""
  echo "═══════════════════════════════════════"
  echo "Iteration $i/$MAX_ITERATIONS — $(date '+%H:%M:%S')"
  echo "═══════════════════════════════════════"
  echo ""

  set_state_num "$NAME" current_iteration "$i"

  PROMPT="${RALPH_CONTEXT_FILES} @${RALPH_PROMPT} \
1. Find the highest-priority task and work only on that task. \
2. Run relevant validation checks (at minimum typecheck/tests when available). \
3. Update planning/progress artifacts with work completed in this iteration. \
4. Make a git commit for that single task. \
ONLY WORK ON A SINGLE TASK. \
If all planned work is complete, output <promise>COMPLETE</promise>."

  RESULT=$(claude --permission-mode acceptEdits "$PROMPT" 2>&1) || true
  echo "$RESULT"

  if [[ "$RESULT" == *"<promise>COMPLETE</promise>"* ]]; then
    echo ""
    echo "═══════════════════════════════════════"
    echo "RALPH complete after $i iterations."
    echo "═══════════════════════════════════════"

    set_state "$NAME" status "complete"
    set_state "$NAME" completed_at "$(now_iso)"

    # Notify if configured
    if [[ -n "${RALPH_NOTIFY_CMD:-}" ]]; then
      printf -v NOTIFY_CMD "$RALPH_NOTIFY_CMD" "Session '$NAME' complete after $i iterations"
      eval "$NOTIFY_CMD" || true
    fi

    exit 0
  fi
done

echo ""
echo "Reached iteration limit ($MAX_ITERATIONS) without COMPLETE signal."
set_state "$NAME" status "stopped"
