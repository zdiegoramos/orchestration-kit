#!/bin/bash
set -eo pipefail

# Description:
#   Reads open issues/PRs/workflow runs, asks an orchestrator model for
#   actionable tasks, and dispatches one workflow run per selected task.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(git rev-parse --show-toplevel)"

WORKFLOW_FILE="${WORKFLOW_FILE:-ai-agent-work.yml}"
TARGET_BRANCH="${TARGET_BRANCH:-main}"
BRANCH_PREFIX="${BRANCH_PREFIX:-ai}"
ORCHESTRATOR_MODEL="${ORCHESTRATOR_MODEL:-sonnet}"

echo "Fetching open issues..."
ISSUES=$(gh issue list --state open --json number,title,body,comments --limit 100)

ISSUE_COUNT=$(echo "$ISSUES" | jq 'length')
echo "Found $ISSUE_COUNT open issues."

if [ "$ISSUE_COUNT" -eq 0 ]; then
  echo "No open issues. Nothing to dispatch."
  exit 0
fi

echo "Fetching open AI PRs..."
OPEN_PRS=$(gh pr list --state open --json number,title,body,headRefName --limit 100 | jq --arg prefix "$BRANCH_PREFIX/" '[.[] | select(.headRefName | startswith($prefix))]')
OPEN_PR_COUNT=$(echo "$OPEN_PRS" | jq 'length')
echo "Found $OPEN_PR_COUNT open AI PRs."

echo "Fetching in-progress workflow runs..."
REPO=$(gh repo view --json nameWithOwner -q .nameWithOwner)
IN_PROGRESS_RUNS=$(gh run list --workflow="$WORKFLOW_FILE" --status=in_progress --json databaseId -q '.[].databaseId')
QUEUED_RUNS=$(gh run list --workflow="$WORKFLOW_FILE" --status=queued --json databaseId -q '.[].databaseId')
ALL_RUN_IDS=$(echo -e "${IN_PROGRESS_RUNS}\n${QUEUED_RUNS}" | grep -v '^$' || true)

IN_PROGRESS_TASKS="[]"
if [ -n "$ALL_RUN_IDS" ]; then
  IN_PROGRESS_TASKS="["
  FIRST=true
  while read -r run_id; do
    INPUTS=$(gh api "repos/$REPO/actions/runs/$run_id" --jq '.inputs // empty')
    if [ -n "$INPUTS" ]; then
      if [ "$FIRST" = true ]; then
        FIRST=false
      else
        IN_PROGRESS_TASKS="${IN_PROGRESS_TASKS},"
      fi
      IN_PROGRESS_TASKS="${IN_PROGRESS_TASKS}${INPUTS}"
    fi
  done <<< "$ALL_RUN_IDS"
  IN_PROGRESS_TASKS="${IN_PROGRESS_TASKS}]"
fi

IN_PROGRESS_COUNT=$(echo "$IN_PROGRESS_TASKS" | jq 'length')
echo "Found $IN_PROGRESS_COUNT in-progress/queued tasks."

echo "Asking orchestrator to analyze issues and plan tasks..."

PROMPT="$(cat "$SCRIPT_DIR/dispatch-prompt.md")

## Runtime Config

- Target branch: $TARGET_BRANCH
- Branch prefix: $BRANCH_PREFIX/

## Open Issues

$ISSUES

## Currently In-Progress Tasks

These tasks are already running or queued on GitHub Actions. Do NOT dispatch work that conflicts with or duplicates these.

$IN_PROGRESS_TASKS

## Open AI PRs

These PRs were created by previous AI runs and are still open (awaiting review/merge). Do NOT dispatch work that duplicates or conflicts with these.

$OPEN_PRS"

RESULT=$(echo "$PROMPT" | claude -p \
  --model "$ORCHESTRATOR_MODEL" \
  --allowedTools "Read,Grep,Glob")

TASKS=$(echo "$RESULT" | sed -n '/<task_json>/,/<\/task_json>/p' | sed '1d;$d')

if ! echo "$TASKS" | jq -e 'type == "array"' > /dev/null 2>&1; then
  echo "Error: Orchestrator did not return a valid JSON array."
  echo "Raw output:"
  echo "$TASKS"
  exit 1
fi

TASK_COUNT=$(echo "$TASKS" | jq 'length')

if [ "$TASK_COUNT" -eq 0 ]; then
  echo "Orchestrator found no tasks to dispatch."
  exit 0
fi

echo ""
echo "Dispatching $TASK_COUNT tasks:"
echo ""

echo "$TASKS" | jq -c '.[]' | while read -r task; do
  BRANCH_NAME=$(echo "$task" | jq -r '.branch_name')
  ISSUE_NUMBERS=$(echo "$task" | jq -c '.issue_numbers')
  TASK_PROMPT=$(echo "$task" | jq -r '.prompt')
  TASK_TARGET_BRANCH=$(echo "$task" | jq -r '.target_branch // empty')

  if [ -z "$TASK_TARGET_BRANCH" ] || [ "$TASK_TARGET_BRANCH" = "null" ]; then
    TASK_TARGET_BRANCH="$TARGET_BRANCH"
  fi

  echo "  -> $BRANCH_NAME"
  echo "     Target: $TASK_TARGET_BRANCH"
  echo "     Issues: $ISSUE_NUMBERS"
  echo "     Prompt: ${TASK_PROMPT:0:80}..."
  echo ""

  gh workflow run "$WORKFLOW_FILE" \
    -f branch_name="$BRANCH_NAME" \
    -f target_branch="$TASK_TARGET_BRANCH" \
    -f issue_numbers="$ISSUE_NUMBERS" \
    -f prompt="$TASK_PROMPT"
done

echo "All tasks dispatched. Run 'gh run list --workflow=$WORKFLOW_FILE' to monitor."
