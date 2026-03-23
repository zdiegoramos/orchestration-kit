#!/bin/bash
set -eo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/sandbox-common.sh"

require_sandbox

RALPH_PARENT_PRD=${RALPH_PARENT_PRD:-}
issues=$(gh issue list --state open --json number,title,body,comments --limit 200)
if [ -n "$RALPH_PARENT_PRD" ]; then
  issues=$(echo "$issues" | jq --arg prd "#$RALPH_PARENT_PRD" '[.[] | select((.body // "") | test($prd))]')
  count=$(echo "$issues" | jq 'length')
  if [ "$count" -eq 0 ]; then
    echo "No open issues found for parent PRD #$RALPH_PARENT_PRD."
    exit 1
  fi
fi
ralph_commits=$(git log --grep="RALPH" -n 10 --format="%H%n%ad%n%B---" --date=short 2>/dev/null || echo "No RALPH commits found")

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROMPT_FILE="$SCRIPT_DIR/../sandcastle/prompt.md"

docker sandbox run claude . -- \
  "$issues Previous RALPH commits: $ralph_commits @$PROMPT_FILE"
