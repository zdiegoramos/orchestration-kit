#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/common.sh"

# ── Parse arguments ─────────────────────────────────────────

NAME=""
BASE_BRANCH="main"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --base)   BASE_BRANCH="$2"; shift 2 ;;
    --base=*) BASE_BRANCH="${1#*=}"; shift ;;
    -*)       echo "Unknown option: $1" >&2; exit 1 ;;
    *)
      if [[ -z "$NAME" ]]; then
        NAME="$1"
      fi
      shift
      ;;
  esac
done

if [[ -z "$NAME" ]]; then
  echo "Usage: ok create <session-name> [--base <branch>]" >&2
  exit 1
fi

# Validate name
if [[ ! "$NAME" =~ ^[a-zA-Z0-9][a-zA-Z0-9_-]*$ ]]; then
  echo "Error: session name must start with alphanumeric, then alphanumeric/hyphens/underscores" >&2
  exit 1
fi

# Check doesn't already exist
if [[ -f "$(session_state_file "$NAME")" ]]; then
  echo "Error: session '$NAME' already exists" >&2
  echo "Run: ok destroy $NAME  (to remove it first)" >&2
  exit 1
fi

BRANCH="$(session_branch "$NAME")"
WORKTREE="$(session_worktree "$NAME")"

echo -e "${BOLD}Creating session:${NC} $NAME"
echo -e "  Branch:   ${CYAN}$BRANCH${NC}"
echo -e "  Base:     ${DIM}$BASE_BRANCH${NC}"
echo -e "  Worktree: ${DIM}$WORKTREE${NC}"

# ── Create git worktree on a new branch ─────────────────────

if git show-ref --verify --quiet "refs/heads/$BRANCH" 2>/dev/null; then
  echo "Error: branch '$BRANCH' already exists" >&2
  exit 1
fi

git worktree add "$WORKTREE" -b "$BRANCH" "$BASE_BRANCH" 2>/dev/null || {
  echo "Error: failed to create worktree for '$BRANCH' from '$BASE_BRANCH'" >&2
  exit 1
}

# ── Copy plan templates into worktree ───────────────────────

mkdir -p "$WORKTREE/plans"
[[ -f "$WORKTREE/plans/prd.md" ]]    || cp "$REPO_ROOT/templates/plans/prd.md" "$WORKTREE/plans/prd.md"
[[ -f "$WORKTREE/plans/tasks.md" ]]  || cp "$REPO_ROOT/templates/plans/tasks.md" "$WORKTREE/plans/tasks.md"
[[ -f "$WORKTREE/progress.txt" ]]    || cp "$REPO_ROOT/templates/progress.txt" "$WORKTREE/progress.txt"

# Symlink .env if it exists in main repo (for secrets)
if [[ -f "$REPO_ROOT/.env" ]] && [[ ! -f "$WORKTREE/.env" ]]; then
  ln -sf "$REPO_ROOT/.env" "$WORKTREE/.env"
fi

# ── Create session state ────────────────────────────────────

SDIR="$(session_dir "$NAME")"
mkdir -p "$SDIR/logs"

cat > "$(session_state_file "$NAME")" <<EOF
{
  "name": "$NAME",
  "status": "created",
  "branch": "$BRANCH",
  "base_branch": "$BASE_BRANCH",
  "worktree": "$WORKTREE",
  "created_at": "$(now_iso)",
  "started_at": null,
  "completed_at": null,
  "sandbox": "$(sandbox_name "$NAME")",
  "max_iterations": 20,
  "current_iteration": 0,
  "pid": null
}
EOF

echo ""
echo -e "${GREEN}Session '$NAME' created.${NC}"
echo ""
echo -e "Next: ${BOLD}ok start $NAME${NC}"
