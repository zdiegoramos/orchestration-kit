#!/usr/bin/env bash
# Shared utilities for the OK session manager.
# Sourced by all scripts/ok/*.sh files.

set -euo pipefail

REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null)" || {
  echo "Error: not inside a git repository" >&2
  exit 1
}

REPO_NAME="$(basename "$REPO_ROOT")"
OK_DIR="$REPO_ROOT/.ok"
SESSIONS_DIR="$OK_DIR/sessions"
WORKTREES_DIR="$OK_DIR/worktrees"

mkdir -p "$SESSIONS_DIR" "$WORKTREES_DIR"

# Ensure .ok is gitignored
if ! grep -qxF '.ok/' "$REPO_ROOT/.gitignore" 2>/dev/null; then
  echo '.ok/' >> "$REPO_ROOT/.gitignore"
fi

# ── Colors ──────────────────────────────────────────────────

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
BOLD='\033[1m'
DIM='\033[2m'
NC='\033[0m'

status_color() {
  case "$1" in
    created)       echo -ne "$CYAN" ;;
    interviewing)  echo -ne "$YELLOW" ;;
    planning)      echo -ne "$YELLOW" ;;
    executing)     echo -ne "$GREEN" ;;
    complete)      echo -ne "$GREEN" ;;
    stopped)       echo -ne "$RED" ;;
    qa)            echo -ne "$BLUE" ;;
    approved)      echo -ne "$MAGENTA" ;;
    merged)        echo -ne "$DIM" ;;
    error)         echo -ne "$RED" ;;
    *)             echo -ne "$NC" ;;
  esac
}

status_icon() {
  case "$1" in
    created)       echo "○" ;;
    interviewing)  echo "◐" ;;
    planning)      echo "◑" ;;
    executing)     echo "●" ;;
    complete)      echo "✓" ;;
    stopped)       echo "■" ;;
    qa)            echo "◉" ;;
    approved)      echo "✓" ;;
    merged)        echo "✓" ;;
    error)         echo "✗" ;;
    *)             echo "?" ;;
  esac
}

# ── Path helpers ────────────────────────────────────────────

session_dir() {
  echo "$SESSIONS_DIR/$1"
}

session_state_file() {
  echo "$(session_dir "$1")/state.json"
}

session_logs_dir() {
  local dir
  dir="$(session_dir "$1")/logs"
  mkdir -p "$dir"
  echo "$dir"
}

session_worktree() {
  echo "$WORKTREES_DIR/$1"
}

session_branch() {
  echo "session/$1"
}

sandbox_name() {
  echo "ok-${REPO_NAME}-${1}"
}

# ── State management ───────────────────────────────────────

require_session() {
  local name="$1"
  if [[ ! -f "$(session_state_file "$name")" ]]; then
    echo "Error: session '$name' does not exist" >&2
    echo "Run: ok create $name" >&2
    exit 1
  fi
}

get_state() {
  local name="$1"
  local key="$2"
  jq -r ".$key // empty" "$(session_state_file "$name")"
}

set_state() {
  local name="$1"
  local key="$2"
  local value="$3"
  local file
  file="$(session_state_file "$name")"
  local tmp
  tmp="$(mktemp)"
  jq --arg v "$value" ".$key = \$v" "$file" > "$tmp" && mv "$tmp" "$file"
}

set_state_num() {
  local name="$1"
  local key="$2"
  local value="$3"
  local file
  file="$(session_state_file "$name")"
  local tmp
  tmp="$(mktemp)"
  jq --argjson v "$value" ".$key = \$v" "$file" > "$tmp" && mv "$tmp" "$file"
}

now_iso() {
  date -u +"%Y-%m-%dT%H:%M:%SZ"
}

# ── Process helpers ─────────────────────────────────────────

is_process_running() {
  local pid="$1"
  [[ -n "$pid" ]] && [[ "$pid" != "null" ]] && kill -0 "$pid" 2>/dev/null
}

# Reconcile session status with actual process state
refresh_session_status() {
  local name="$1"
  local status pid log_file

  status="$(get_state "$name" status)"
  pid="$(get_state "$name" pid)"

  if [[ "$status" == "executing" ]] && ! is_process_running "$pid"; then
    log_file="$(session_logs_dir "$name")/ralph.log"
    if [[ -f "$log_file" ]] && grep -q '<promise>COMPLETE</promise>' "$log_file" 2>/dev/null; then
      set_state "$name" status "complete"
      set_state "$name" completed_at "$(now_iso)"
    else
      set_state "$name" status "stopped"
    fi
  fi
}

# Count ralph iterations from the log
get_iteration_info() {
  local name="$1"
  local log_file
  log_file="$(session_logs_dir "$name")/ralph.log"
  if [[ -f "$log_file" ]]; then
    local last
    last=$(grep -oE 'Iteration [0-9]+' "$log_file" | tail -1 | grep -oE '[0-9]+' || echo "0")
    local max
    max="$(get_state "$name" max_iterations)"
    echo "${last:-0}/${max:-?}"
  else
    echo "0/$(get_state "$name" max_iterations)"
  fi
}

# ── Time helpers ────────────────────────────────────────────

elapsed_since() {
  local start="$1"
  [[ -z "$start" || "$start" == "null" ]] && echo "-" && return

  local start_epoch now_epoch diff
  if [[ "$(uname)" == "Darwin" ]]; then
    start_epoch=$(date -jf "%Y-%m-%dT%H:%M:%SZ" "$start" +%s 2>/dev/null || echo 0)
  else
    start_epoch=$(date -d "$start" +%s 2>/dev/null || echo 0)
  fi
  now_epoch=$(date +%s)
  diff=$((now_epoch - start_epoch))

  if (( diff < 0 )); then
    echo "-"
  elif (( diff < 60 )); then
    echo "${diff}s"
  elif (( diff < 3600 )); then
    echo "$((diff / 60))m"
  else
    echo "$((diff / 3600))h$((diff % 3600 / 60))m"
  fi
}

# ── Session listing ─────────────────────────────────────────

list_sessions() {
  local sessions=()
  for state_file in "$SESSIONS_DIR"/*/state.json; do
    [[ -f "$state_file" ]] || continue
    sessions+=("$(basename "$(dirname "$state_file")")")
  done
  echo "${sessions[@]}"
}

print_session_table() {
  local sessions=()
  for state_file in "$SESSIONS_DIR"/*/state.json; do
    [[ -f "$state_file" ]] || continue
    sessions+=("$(basename "$(dirname "$state_file")")")
  done

  if [[ ${#sessions[@]} -eq 0 ]]; then
    echo "No sessions. Run: ok create <name>"
    return
  fi

  # Header
  printf "  ${BOLD}%-4s %-16s %-14s %-20s %-8s %-8s${NC}\n" \
    "#" "Session" "Status" "Branch" "Iter" "Time"
  printf "  %-4s %-16s %-14s %-20s %-8s %-8s\n" \
    "──" "────────────────" "──────────────" "────────────────────" "────────" "────────"

  local i=1
  for name in "${sessions[@]}"; do
    refresh_session_status "$name"

    local status branch started_at iter
    status="$(get_state "$name" status)"
    branch="$(get_state "$name" branch)"
    started_at="$(get_state "$name" started_at)"
    iter="$(get_iteration_info "$name")"

    local color icon elapsed
    color="$(status_color "$status")"
    icon="$(status_icon "$status")"
    elapsed="$(elapsed_since "$started_at")"

    # Truncate branch name to fit column
    local branch_display="${branch:0:20}"

    printf "  %-4s %-16s ${color}%-2s %-11s${NC} %-20s %-8s %-8s\n" \
      "$i" "$name" "$icon" "$status" "$branch_display" "$iter" "$elapsed"

    ((i++))
  done
}
