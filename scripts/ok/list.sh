#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/common.sh"

# If a session name is passed, show detailed status for that session.
# Otherwise, show the table of all sessions.

NAME="${1:-}"

if [[ -n "$NAME" ]]; then
  require_session "$NAME"
  refresh_session_status "$NAME"

  status="$(get_state "$NAME" status)"
  branch="$(get_state "$NAME" branch)"
  base="$(get_state "$NAME" base_branch)"
  worktree="$(get_state "$NAME" worktree)"
  created="$(get_state "$NAME" created_at)"
  started="$(get_state "$NAME" started_at)"
  completed="$(get_state "$NAME" completed_at)"
  pid="$(get_state "$NAME" pid)"
  iter="$(get_iteration_info "$NAME")"

  color="$(status_color "$status")"
  icon="$(status_icon "$status")"

  echo ""
  echo -e "  ${BOLD}Session:${NC}     $NAME"
  echo -e "  ${BOLD}Status:${NC}      ${color}${icon} ${status}${NC}"
  echo -e "  ${BOLD}Branch:${NC}      $branch"
  echo -e "  ${BOLD}Base:${NC}        $base"
  echo -e "  ${BOLD}Worktree:${NC}    $worktree"
  echo -e "  ${BOLD}Iterations:${NC}  $iter"
  echo -e "  ${BOLD}Created:${NC}     $created"
  [[ -n "$started" && "$started" != "null" ]] && echo -e "  ${BOLD}Started:${NC}     $started ($(elapsed_since "$started") ago)"
  [[ -n "$completed" && "$completed" != "null" ]] && echo -e "  ${BOLD}Completed:${NC}   $completed"
  if [[ -n "$pid" && "$pid" != "null" ]]; then
    if is_process_running "$pid"; then
      echo -e "  ${BOLD}PID:${NC}         $pid ${GREEN}(running)${NC}"
    else
      echo -e "  ${BOLD}PID:${NC}         $pid ${DIM}(exited)${NC}"
    fi
  fi
  echo ""
else
  echo ""
  print_session_table
  echo ""
fi
