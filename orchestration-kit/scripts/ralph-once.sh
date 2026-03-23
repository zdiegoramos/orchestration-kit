#!/bin/bash
set -eo pipefail

# One autonomous RALPH iteration.
#
# Environment variables:
#   RALPH_CONTEXT_FILES: Space-separated @file references passed to Claude
#                        default: "@plans/prd.md @progress.txt"
#   RALPH_MODEL: Claude model alias (optional)

RALPH_CONTEXT_FILES=${RALPH_CONTEXT_FILES:-"@plans/prd.md @progress.txt"}
RALPH_MODEL=${RALPH_MODEL:-}
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

PROMPT="${RALPH_CONTEXT_FILES} @${SCRIPT_DIR}/ralph-prompt.md\
1. Find the highest-priority task and work only on that task. \
2. Run relevant validation checks (at minimum typecheck/tests when available). \
3. Update planning/progress artifacts with work completed in this iteration. \
4. Make a git commit for that single task. \
ONLY WORK ON A SINGLE TASK. \
If all planned work is complete, output <promise>COMPLETE</promise>."

if [ -n "$RALPH_MODEL" ]; then
  claude --permission-mode acceptEdits --model "$RALPH_MODEL" "$PROMPT"
else
  claude --permission-mode acceptEdits "$PROMPT"
fi
