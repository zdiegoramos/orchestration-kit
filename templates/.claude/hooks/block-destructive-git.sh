#!/bin/bash
# Blocks destructive git commands from Claude shell tool usage.

set -euo pipefail

INPUT=$(cat)
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty')

if echo "$COMMAND" | grep -Eq '(^|[[:space:]])git[[:space:]]+(reset[[:space:]]+--hard|checkout[[:space:]]+--|clean[[:space:]]+-fdx)'; then
  echo "Blocked destructive git command. Use a safer alternative." >&2
  exit 2
fi
