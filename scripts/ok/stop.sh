#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/common.sh"

NAME="${1:-}"

if [[ -z "$NAME" ]]; then
  echo "Usage: ok stop <session-name>" >&2
  exit 1
fi

require_session "$NAME"

STATUS="$(get_state "$NAME" status)"
PID="$(get_state "$NAME" pid)"

if [[ "$STATUS" != "executing" ]]; then
  echo "Session '$NAME' is not executing (status: $STATUS)."
  exit 0
fi

if is_process_running "$PID"; then
  echo -e "Stopping ralph loop (PID $PID)..."

  # Kill the process group to ensure child processes are also stopped
  kill -- -"$PID" 2>/dev/null || kill "$PID" 2>/dev/null || true

  # Wait briefly for clean shutdown
  for i in 1 2 3 4 5; do
    if ! is_process_running "$PID"; then
      break
    fi
    sleep 1
  done

  # Force kill if still running
  if is_process_running "$PID"; then
    kill -9 "$PID" 2>/dev/null || true
  fi

  echo -e "${GREEN}Stopped.${NC}"
else
  echo "Process $PID already exited."
fi

set_state "$NAME" status "stopped"
echo -e "Session '$NAME' status → ${YELLOW}stopped${NC}"
echo ""
echo -e "To resume: ${BOLD}ok start $NAME${NC}"
