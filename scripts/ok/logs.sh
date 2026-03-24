#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/common.sh"

NAME=""
FOLLOW=0

while [[ $# -gt 0 ]]; do
  case "$1" in
    --follow|-f) FOLLOW=1; shift ;;
    -*) echo "Unknown option: $1" >&2; exit 1 ;;
    *)
      if [[ -z "$NAME" ]]; then
        NAME="$1"
      fi
      shift
      ;;
  esac
done

if [[ -z "$NAME" ]]; then
  echo "Usage: ok logs <session-name> [--follow]" >&2
  exit 1
fi

require_session "$NAME"

LOG_FILE="$(session_logs_dir "$NAME")/ralph.log"

if [[ ! -f "$LOG_FILE" ]]; then
  echo "No logs yet for session '$NAME'."
  echo "The ralph loop may not have started."
  exit 0
fi

if [[ "$FOLLOW" -eq 1 ]]; then
  tail -f "$LOG_FILE"
else
  less -R "$LOG_FILE"
fi
