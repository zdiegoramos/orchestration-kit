#!/bin/bash
set -euo pipefail

# Sets secrets required by the ai-agent-work workflow from a root .env file.
#
# Required keys in .env:
#   1. CLAUDE_CODE_OAUTH_TOKEN
#   2. GH_READ_TOKEN

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
ENV_FILE="$ROOT_DIR/.env"

error() {
  echo "Error: $1" >&2
  exit 1
}

command -v gh >/dev/null 2>&1 || error "GitHub CLI (gh) is not installed or not in PATH."

if [ ! -f "$ENV_FILE" ]; then
  error "Missing $ENV_FILE. Create it first and add: CLAUDE_CODE_OAUTH_TOKEN=<token> and GH_READ_TOKEN=<github_token>, then run this script again."
fi

extract_env_var() {
  local key="$1"
  local line
  line=$(grep -E "^[[:space:]]*${key}=" "$ENV_FILE" | head -n 1 || true)
  if [ -z "$line" ]; then
    echo ""
    return
  fi

  line="${line#*=}"
  line="${line#\"}"
  line="${line%\"}"
  line="${line#\'}"
  line="${line%\'}"
  echo "$line"
}

validate_secret() {
  local name="$1"
  local value="$2"

  [ -n "$value" ] || error "$name is missing or empty in $ENV_FILE."

  if [[ "$value" =~ [[:space:]] ]]; then
    error "$name contains whitespace, which is not expected for a token."
  fi

  if [[ "$value" =~ ^(CHANGEME|changeme|REPLACE_ME|replace_me|YOUR_.*|your_.*|example|EXAMPLE|<.*>)$ ]]; then
    error "$name looks like a placeholder value in $ENV_FILE."
  fi

  if [ "${#value}" -lt 20 ]; then
    error "$name appears too short to be a valid token."
  fi
}

validate_gh_token_shape() {
  local value="$1"
  if [[ ! "$value" =~ ^(ghp_|github_pat_|gho_|ghu_|ghs_|ghr_) ]]; then
    error "GH_READ_TOKEN does not look like a GitHub token (expected prefix ghp_, github_pat_, gho_, ghu_, ghs_, or ghr_)."
  fi
}

CLAUDE_CODE_OAUTH_TOKEN="$(extract_env_var "CLAUDE_CODE_OAUTH_TOKEN")"
GH_READ_TOKEN="$(extract_env_var "GH_READ_TOKEN")"

validate_secret "CLAUDE_CODE_OAUTH_TOKEN" "$CLAUDE_CODE_OAUTH_TOKEN"
validate_secret "GH_READ_TOKEN" "$GH_READ_TOKEN"
validate_gh_token_shape "$GH_READ_TOKEN"

REPO=$(gh repo view --json nameWithOwner -q .nameWithOwner 2>/dev/null || true)
if [ -z "$REPO" ]; then
  error "Could not determine repository. Ensure this is a git repo with a GitHub remote and gh is authenticated."
fi

echo "Setting up secrets for: $REPO"
echo "Using secrets from: $ENV_FILE"

echo "$CLAUDE_CODE_OAUTH_TOKEN" | gh secret set CLAUDE_CODE_OAUTH_TOKEN --repo "$REPO"
echo "Set: CLAUDE_CODE_OAUTH_TOKEN"

echo "$GH_READ_TOKEN" | gh secret set GH_READ_TOKEN --repo "$REPO"
echo "Set: GH_READ_TOKEN"

echo ""
echo "Configured secrets:"
gh secret list --repo "$REPO"
