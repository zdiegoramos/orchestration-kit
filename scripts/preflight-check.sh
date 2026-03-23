#!/bin/bash
set -eo pipefail

WORKFLOW_FILE="${WORKFLOW_FILE:-ai-agent-work.yml}"

require_cmd() {
  local cmd="$1"
  if ! command -v "$cmd" >/dev/null 2>&1; then
    echo "Missing dependency: $cmd"
    return 1
  fi
}

echo "Running orchestration preflight checks..."

require_cmd gh
require_cmd jq
require_cmd claude
require_cmd git

if ! gh auth status >/dev/null 2>&1; then
  echo "GitHub CLI is not authenticated. Run: gh auth login"
  exit 1
fi

REPO=$(gh repo view --json nameWithOwner -q .nameWithOwner 2>/dev/null || true)
if [ -z "$REPO" ]; then
  echo "Could not resolve GitHub repo from current directory."
  exit 1
fi

echo "Repo: $REPO"

if [ ! -f ".github/workflows/$WORKFLOW_FILE" ]; then
  echo "Missing workflow: .github/workflows/$WORKFLOW_FILE"
  exit 1
fi

MISSING_SECRETS=0
if ! gh secret list --repo "$REPO" | grep -q '^CLAUDE_CODE_OAUTH_TOKEN'; then
  echo "Missing GitHub secret: CLAUDE_CODE_OAUTH_TOKEN"
  MISSING_SECRETS=1
fi
if ! gh secret list --repo "$REPO" | grep -q '^GH_READ_TOKEN'; then
  echo "Missing GitHub secret: GH_READ_TOKEN"
  MISSING_SECRETS=1
fi

if [ "$MISSING_SECRETS" -eq 1 ]; then
  echo "Run: bash scripts/setup-github-secrets.sh"
  exit 1
fi

echo "Preflight OK. You are ready to orchestrate."
