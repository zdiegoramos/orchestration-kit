# AI Orchestration Kit

This folder contains only the automation layer for running issue-driven AI coding workers on GitHub Actions.

It does not include any product/app code.

## What is included

1. `.github/workflows/ai-agent-work.yml`
2. `scripts/dispatch.sh`
3. `scripts/dispatch-prompt.md`
4. `scripts/worker-run.sh`
5. `scripts/worker-prompt.md`
6. `scripts/setup-github-secrets.sh`
7. `scripts/ralph-once.sh`
8. `scripts/ralph-loop.sh`
9. `scripts/ralph-prompt.md`
10. `scripts/feedback-feature.md` (optional prompt template example)

## Prerequisites

1. GitHub repository with Actions enabled
2. GitHub CLI installed and authenticated (`gh auth login`)
3. Claude Code CLI installed (`bun add -g @anthropic-ai/claude-code`)
4. `jq` installed

## Install into a target repo

From the target repo root, copy this folder's contents preserving paths:

1. Copy `.github/workflows/ai-agent-work.yml` to `.github/workflows/`
2. Copy all files in `scripts/` into your repo `scripts/`

Minimum required files to run the system:

1. `.github/workflows/ai-agent-work.yml`
2. `scripts/dispatch.sh`
3. `scripts/dispatch-prompt.md`
4. `scripts/worker-run.sh`
5. `scripts/worker-prompt.md`
6. `scripts/setup-github-secrets.sh`
7. `scripts/ralph-once.sh`
8. `scripts/ralph-loop.sh`
9. `scripts/ralph-prompt.md`

Then run:

```bash
bash scripts/setup-github-secrets.sh
```

This sets these repository secrets:

1. `CLAUDE_CODE_OAUTH_TOKEN`
2. `GH_READ_TOKEN`

Mark scripts executable:

```bash
chmod +x scripts/dispatch.sh scripts/worker-run.sh scripts/setup-github-secrets.sh scripts/ralph-once.sh scripts/ralph-loop.sh
```

## Daily usage (GitHub Actions dispatcher)

```bash
bash scripts/dispatch.sh
```

Monitor runs:

```bash
gh run list --workflow=ai-agent-work.yml
```

## RALPH loop usage (local autonomous iteration)

Single iteration:

```bash
bash scripts/ralph-once.sh
```

Repeated iterations:

```bash
bash scripts/ralph-loop.sh 10
```

Optional context override:

```bash
RALPH_CONTEXT_FILES='@plans/prd.md @plans/tasks.md @progress.txt' bash scripts/ralph-loop.sh 10
```

The loop stops early if the agent returns `<promise>COMPLETE</promise>`.

## Required issue format for best results

Use issue bodies with:

1. `AFK` or `HITL`
2. Acceptance criteria bullets
3. Optional `Blocked by` section with issue numbers

## Notes

1. The worker creates branches with prefix `ai/`.
2. The default target branch is `main`.
3. The workflow auto-installs repo dependencies only when `package.json` exists.
4. You can override defaults using environment variables in `scripts/dispatch.sh`.
5. The RALPH loop is planning-driven and expects planning/progress files to exist.

## Optional configuration

Dispatcher environment variables:

1. `WORKFLOW_FILE` (default: `ai-agent-work.yml`)
2. `TARGET_BRANCH` (default: `main`)
3. `BRANCH_PREFIX` (default: `ai`)
4. `ORCHESTRATOR_MODEL` (default: `sonnet`)

RALPH environment variables:

1. `RALPH_CONTEXT_FILES` (default: `@plans/prd.md @progress.txt`)
2. `RALPH_MODEL` (optional model override)
3. `RALPH_NOTIFY_CMD` (optional command for completion notifications)

How to add extra context or skills:

1. Put guidance files in your target repo (for example `docs/ai-guidelines.md` or `.claude/skills/.../SKILL.md`).
2. Include them in `RALPH_CONTEXT_FILES`, for example:

```bash
RALPH_CONTEXT_FILES='@plans/prd.md @progress.txt @docs/ai-guidelines.md @.claude/skills/my-skill/SKILL.md' bash scripts/ralph-loop.sh 10
```

3. For dispatcher/worker mode, include persistent behavior rules in `scripts/dispatch-prompt.md` and `scripts/worker-prompt.md`.
