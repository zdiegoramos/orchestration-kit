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

ensure_env_vars_file() {
  local file_path="$1"
  local missing_keys=()

  if [ ! -f "$file_path" ]; then
    cat > "$file_path" <<'EOF'
CLAUDE_CODE_OAUTH_TOKEN=
GH_READ_TOKEN=

EOF
    echo "create $file_path"
    return
  fi

  if ! grep -Eq '^[[:space:]]*CLAUDE_CODE_OAUTH_TOKEN=' "$file_path"; then
    missing_keys+=("CLAUDE_CODE_OAUTH_TOKEN")
  fi
  if ! grep -Eq '^[[:space:]]*GH_READ_TOKEN=' "$file_path"; then
    missing_keys+=("GH_READ_TOKEN")
  fi

  if [ "${#missing_keys[@]}" -eq 0 ]; then
    return
  fi

  local tmp_file
  tmp_file="$(mktemp)"

  {
    for key in "${missing_keys[@]}"; do
      printf '%s=\n' "$key"
    done
    printf '\n'
    cat "$file_path"
  } > "$tmp_file"

  mv "$tmp_file" "$file_path"
  echo "update $file_path (prepended: ${missing_keys[*]})"
}

ensure_env_vars_file "$TARGET_REPO/.env"
ensure_env_vars_file "$TARGET_REPO/.env.example"

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
copy_file "$KIT_ROOT/templates/.gitignore" "$TARGET_REPO/.gitignore"
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
echo "  2. Add token values in .env (CLAUDE_CODE_OAUTH_TOKEN, GH_READ_TOKEN)"
echo "  3. gh auth login"
echo "  4. bash scripts/setup-github-secrets.sh"
echo "  5. bash scripts/preflight-check.sh"
echo "  6. bash scripts/dispatch.sh"
