#!/bin/bash
set -eo pipefail

# Installs orchestration kit files into another repository.
# Usage:
#   bash orchestration-kit/scripts/install-into-target.sh /path/to/target [--force]

if [ -z "${1:-}" ]; then
  echo "Usage: $0 /path/to/target [--force]"
  exit 1
fi

TARGET_REPO="$1"
shift || true

FORCE=0
for arg in "$@"; do
  case "$arg" in
    --force) FORCE=1 ;;
    *)
      echo "Unknown option: $arg"
      exit 1
      ;;
  esac
done

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
KIT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

if [ ! -d "$TARGET_REPO/.git" ]; then
  echo "Target is not a git repository: $TARGET_REPO"
  exit 1
fi

copy_file() {
  local src="$1"
  local dest="$2"

  mkdir -p "$(dirname "$dest")"

  if [ -f "$dest" ] && [ "$FORCE" -ne 1 ]; then
    echo "skip  $dest (exists, use --force to overwrite)"
    return
  fi

  cp "$src" "$dest"
  echo "copy  $dest"
}

echo "Installing orchestration kit into: $TARGET_REPO"

copy_file "$KIT_ROOT/.github/workflows/ai-agent-work.yml" "$TARGET_REPO/.github/workflows/ai-agent-work.yml"

for src in "$KIT_ROOT"/scripts/*.sh "$KIT_ROOT"/scripts/*.md; do
  [ -f "$src" ] || continue
  file_name="$(basename "$src")"
  if [ "$file_name" = "install-into-target.sh" ]; then
    continue
  fi
  copy_file "$src" "$TARGET_REPO/scripts/$file_name"
done

copy_file "$KIT_ROOT/templates/.claude/settings.json" "$TARGET_REPO/.claude/settings.json"
copy_file "$KIT_ROOT/templates/.claude/hooks/block-destructive-git.sh" "$TARGET_REPO/.claude/hooks/block-destructive-git.sh"
copy_file "$KIT_ROOT/templates/.github/ISSUE_TEMPLATE/ai-afk-task.yml" "$TARGET_REPO/.github/ISSUE_TEMPLATE/ai-afk-task.yml"
copy_file "$KIT_ROOT/templates/plans/prd.md" "$TARGET_REPO/plans/prd.md"
copy_file "$KIT_ROOT/templates/plans/tasks.md" "$TARGET_REPO/plans/tasks.md"
copy_file "$KIT_ROOT/templates/progress.txt" "$TARGET_REPO/progress.txt"

mkdir -p "$TARGET_REPO/sandcastle"
cp -R "$KIT_ROOT/sandcastle/." "$TARGET_REPO/sandcastle/"
echo "copy  $TARGET_REPO/sandcastle/*"

chmod +x "$TARGET_REPO/scripts"/*.sh || true
chmod +x "$TARGET_REPO/.claude/hooks"/*.sh || true

echo ""
echo "Install complete."
echo "Next steps:"
echo "  1. cd $TARGET_REPO"
echo "  2. gh auth login"
echo "  3. bash scripts/setup-github-secrets.sh"
echo "  4. bash scripts/preflight-check.sh"
echo "  5. bash scripts/dispatch.sh"
