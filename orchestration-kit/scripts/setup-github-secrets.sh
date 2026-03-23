#!/bin/bash
set -eo pipefail

# Sets secrets required by the ai-agent-work workflow.
#
# Secrets:
#   1. CLAUDE_CODE_OAUTH_TOKEN
#   2. GH_READ_TOKEN

REPO=$(gh repo view --json nameWithOwner -q .nameWithOwner 2>/dev/null)

if [ -z "$REPO" ]; then
  echo "Error: Could not determine repository. Ensure this is a git repo with a GitHub remote."
  exit 1
fi

echo "Setting up secrets for: $REPO"
echo ""

echo "Step 1: CLAUDE_CODE_OAUTH_TOKEN"
echo "  Get it from: claude config get oauthToken"
EXISTING=$(gh secret list --repo "$REPO" 2>/dev/null | grep "CLAUDE_CODE_OAUTH_TOKEN" || true)
if [ -n "$EXISTING" ]; then
  echo "  Secret exists. Overwrite? (y/N)"
  read -r OVERWRITE
  if [[ "$OVERWRITE" == "y" || "$OVERWRITE" == "Y" ]]; then
    echo "  Paste CLAUDE_CODE_OAUTH_TOKEN (input hidden):"
    read -rs TOKEN
    echo "$TOKEN" | gh secret set CLAUDE_CODE_OAUTH_TOKEN --repo "$REPO"
    echo "  Set."
  else
    echo "  Skipped."
  fi
else
  echo "  Paste CLAUDE_CODE_OAUTH_TOKEN (input hidden):"
  read -rs TOKEN
  echo "$TOKEN" | gh secret set CLAUDE_CODE_OAUTH_TOKEN --repo "$REPO"
  echo "  Set."
fi

echo ""
echo "Step 2: GH_READ_TOKEN"
echo "  Create a PAT at: https://github.com/settings/tokens"
echo "  Scope: repo (or public_repo for public repos)"
EXISTING=$(gh secret list --repo "$REPO" 2>/dev/null | grep "GH_READ_TOKEN" || true)
if [ -n "$EXISTING" ]; then
  echo "  Secret exists. Overwrite? (y/N)"
  read -r OVERWRITE
  if [[ "$OVERWRITE" == "y" || "$OVERWRITE" == "Y" ]]; then
    echo "  Paste GH_READ_TOKEN (input hidden):"
    read -rs TOKEN
    echo "$TOKEN" | gh secret set GH_READ_TOKEN --repo "$REPO"
    echo "  Set."
  else
    echo "  Skipped."
  fi
else
  echo "  Paste GH_READ_TOKEN (input hidden):"
  read -rs TOKEN
  echo "$TOKEN" | gh secret set GH_READ_TOKEN --repo "$REPO"
  echo "  Set."
fi

echo ""
echo "Configured secrets:"
gh secret list --repo "$REPO"
