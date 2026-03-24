#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/common.sh"

# ── Parse arguments ─────────────────────────────────────────

NAME="${1:-}"
MAX_ITERATIONS="${2:-20}"

if [[ -z "$NAME" ]]; then
  echo "Usage: ok start <session-name> [max-iterations]" >&2
  exit 1
fi

require_session "$NAME"

STATUS="$(get_state "$NAME" status)"
WORKTREE="$(get_state "$NAME" worktree)"
BRANCH="$(get_state "$NAME" branch)"

if [[ "$STATUS" == "executing" ]]; then
  echo "Session '$NAME' is already executing." >&2
  echo "Run 'ok dashboard' to monitor or 'ok stop $NAME' to stop." >&2
  exit 1
fi

if [[ "$STATUS" != "created" && "$STATUS" != "stopped" ]]; then
  echo "Session '$NAME' is in status '$STATUS' — cannot start." >&2
  echo "Use 'ok destroy $NAME' then 'ok create $NAME' to reset." >&2
  exit 1
fi

set_state_num "$NAME" max_iterations "$MAX_ITERATIONS"
set_state "$NAME" started_at "$(now_iso)"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SDIR="$(session_dir "$NAME")"
LOGS_DIR="$(session_logs_dir "$NAME")"

# ── Phase 1: Interactive interview ──────────────────────────

echo ""
echo -e "${BOLD}╔══════════════════════════════════════════════════╗${NC}"
echo -e "${BOLD}║     Session: ${CYAN}$NAME${NC}${BOLD}$(printf '%*s' $((35 - ${#NAME})) '')║${NC}"
echo -e "${BOLD}╚══════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${YELLOW}Phase 1: Discovery Interview${NC}"
echo -e "Claude will interview you about your intent."
echo -e "When planning is complete, exit Claude (Ctrl+C or /exit)."
echo -e "The ralph loop will start automatically."
echo ""
echo -e "${DIM}──────────────────────────────────────────────────${NC}"
echo ""

set_state "$NAME" status "interviewing"

GRILL_PROMPT="$(cat "$SCRIPT_DIR/grill-prompt.md")"

# Run claude interactively in the session worktree.
# The grill prompt is passed as the initial message — claude processes it
# then enters interactive mode for the Q&A interview.
cd "$WORKTREE"
claude --permission-mode acceptEdits "$GRILL_PROMPT" || true

echo ""
echo -e "${DIM}──────────────────────────────────────────────────${NC}"
echo ""

# ── Phase 2: Validate planning artifacts ────────────────────

set_state "$NAME" status "planning"

PRD_FILE="$WORKTREE/plans/prd.md"
TASKS_FILE="$WORKTREE/plans/tasks.md"

if [[ ! -f "$PRD_FILE" ]] || [[ ! -s "$PRD_FILE" ]]; then
  echo -e "${RED}PRD not generated (plans/prd.md missing or empty).${NC}"
  echo -e "Run ${BOLD}ok start $NAME${NC} again to retry."
  set_state "$NAME" status "stopped"
  exit 1
fi

# Check PRD has real content (not just the template)
PRD_LINES=$(wc -l < "$PRD_FILE" | tr -d ' ')
if (( PRD_LINES < 15 )); then
  echo -e "${YELLOW}Warning: PRD looks thin ($PRD_LINES lines). Proceeding anyway.${NC}"
fi

echo -e "${GREEN}✓ Planning artifacts found.${NC}"

# Commit planning artifacts on the session branch
cd "$WORKTREE"
git add plans/ progress.txt 2>/dev/null || true
git commit -m "OK($NAME): planning artifacts" --allow-empty -q 2>/dev/null || true

# ── Phase 3: Start ralph loop ───────────────────────────────

echo ""
echo -e "${YELLOW}Phase 2: Starting execution...${NC}"

set_state "$NAME" status "executing"

# Launch the session runner in the background
nohup bash "$SCRIPT_DIR/session-runner.sh" "$NAME" "$MAX_ITERATIONS" \
  > "$LOGS_DIR/ralph.log" 2>&1 &

RALPH_PID=$!
set_state_num "$NAME" pid "$RALPH_PID"

echo ""
echo -e "${GREEN}╔══════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║  Session '${NAME}' is now executing!$(printf '%*s' $((28 - ${#NAME})) '')║${NC}"
echo -e "${GREEN}║                                                  ║${NC}"
echo -e "${GREEN}║  Ralph PID:      ${NC}${RALPH_PID}$(printf '%*s' $((32 - ${#RALPH_PID})) '')${GREEN}║${NC}"
echo -e "${GREEN}║  Max iterations: ${NC}${MAX_ITERATIONS}$(printf '%*s' $((32 - ${#MAX_ITERATIONS})) '')${GREEN}║${NC}"
echo -e "${GREEN}║  Worktree:       ${NC}${WORKTREE: -30}  ${GREEN}║${NC}"
echo -e "${GREEN}╚══════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "  ${BOLD}ok dashboard${NC}        — monitor progress"
echo -e "  ${BOLD}ok logs $NAME${NC}  — view execution logs"
echo -e "  ${BOLD}ok stop $NAME${NC}  — stop execution"
echo ""
