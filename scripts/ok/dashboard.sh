#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/common.sh"

# pm2-style live dashboard with auto-refresh.
# Press q or Ctrl+C to exit.

REFRESH_INTERVAL=3

cleanup() {
  tput cnorm 2>/dev/null || true  # Restore cursor
  echo ""
  exit 0
}
trap cleanup INT TERM EXIT

# Hide cursor during dashboard display
tput civis 2>/dev/null || true

while true; do
  # Clear screen and move to top
  tput clear 2>/dev/null || printf '\033[2J\033[H'

  echo ""
  echo -e "  ${BOLD}OK Dashboard${NC} — ${CYAN}$REPO_NAME${NC}$(printf '%30s' "")${DIM}↻ ${REFRESH_INTERVAL}s  q: quit${NC}"
  echo ""

  print_session_table

  echo ""
  echo -e "  ${DIM}Actions: ok start | ok stop | ok qa | ok approve | ok logs | ok destroy${NC}"
  echo ""

  # Wait for REFRESH_INTERVAL seconds, but check for 'q' keypress
  if read -rsn1 -t "$REFRESH_INTERVAL" key 2>/dev/null; then
    case "$key" in
      q|Q) break ;;
    esac
  fi
done
