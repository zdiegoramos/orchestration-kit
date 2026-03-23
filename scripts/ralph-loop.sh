#!/bin/bash
set -eo pipefail

# Repeated autonomous RALPH iterations until COMPLETE or max iterations reached.
#
# Usage: ./scripts/ralph-loop.sh <iterations>
#
# Environment variables:
#   RALPH_CONTEXT_FILES: Space-separated @file references passed to Claude
#                        default: "@plans/prd.md @plans/tasks.md @progress.txt"
#   RALPH_MODEL: Claude model alias (optional)
#   RALPH_NOTIFY_CMD: shell command with %s placeholder for message (optional)
#                     example: RALPH_NOTIFY_CMD='echo "%s"'

if [ -z "$1" ]; then
  echo "Usage: $0 <iterations>"
  exit 1
fi

ITERATIONS="$1"
RALPH_CONTEXT_FILES=${RALPH_CONTEXT_FILES:-"@plans/prd.md @plans/tasks.md @progress.txt"}
RALPH_MODEL=${RALPH_MODEL:-}
RALPH_NOTIFY_CMD=${RALPH_NOTIFY_CMD:-}
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

for ((i=1; i<=ITERATIONS; i++)); do
  echo "Iteration $i"
  echo "--------------------------------"

  PROMPT="${RALPH_CONTEXT_FILES} @${SCRIPT_DIR}/ralph-prompt.md\
1. Find the highest-priority task and work only on that task. \
2. Run relevant validation checks (at minimum typecheck/tests when available). \
3. Update planning/progress artifacts with work completed in this iteration. \
4. Make a git commit for that single task. \
ONLY WORK ON A SINGLE TASK. \
If all planned work is complete, output <promise>COMPLETE</promise>."

  if [ -n "$RALPH_MODEL" ]; then
    RESULT=$(claude --permission-mode acceptEdits --model "$RALPH_MODEL" "$PROMPT")
  else
    RESULT=$(claude --permission-mode acceptEdits "$PROMPT")
  fi

  echo "$RESULT"

  if [[ "$RESULT" == *"<promise>COMPLETE</promise>"* ]]; then
    MESSAGE="RALPH complete after $i iterations"
    echo "$MESSAGE"

    if [ -n "$RALPH_NOTIFY_CMD" ]; then
      # shellcheck disable=SC2059
      printf -v NOTIFY_CMD "$RALPH_NOTIFY_CMD" "$MESSAGE"
      eval "$NOTIFY_CMD"
    fi

    exit 0
  fi
done

echo "Reached iteration limit ($ITERATIONS) without COMPLETE signal."
