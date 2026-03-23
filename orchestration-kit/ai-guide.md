# AI Guide: Reusable AI Orchestration (App-Agnostic)

This guide explains how to run autonomous AI coding orchestration in any repository.

It documents only the orchestration layer, not product functionality.

## Included Orchestration Kit

Use the reusable kit in [orchestration-kit/README.md](orchestration-kit/README.md).

It contains only:

1. Workflow: [orchestration-kit/.github/workflows/ai-agent-work.yml](orchestration-kit/.github/workflows/ai-agent-work.yml)
2. Dispatcher: [orchestration-kit/scripts/dispatch.sh](orchestration-kit/scripts/dispatch.sh)
3. Orchestrator prompt: [orchestration-kit/scripts/dispatch-prompt.md](orchestration-kit/scripts/dispatch-prompt.md)
4. Worker runner: [orchestration-kit/scripts/worker-run.sh](orchestration-kit/scripts/worker-run.sh)
5. Worker contract: [orchestration-kit/scripts/worker-prompt.md](orchestration-kit/scripts/worker-prompt.md)
6. Secret setup helper: [orchestration-kit/scripts/setup-github-secrets.sh](orchestration-kit/scripts/setup-github-secrets.sh)
7. RALPH single iteration: [orchestration-kit/scripts/ralph-once.sh](orchestration-kit/scripts/ralph-once.sh)
8. RALPH iterative loop: [orchestration-kit/scripts/ralph-loop.sh](orchestration-kit/scripts/ralph-loop.sh)
9. RALPH loop contract: [orchestration-kit/scripts/ralph-prompt.md](orchestration-kit/scripts/ralph-prompt.md)
10. Optional prompt template: [orchestration-kit/scripts/feedback-feature.md](orchestration-kit/scripts/feedback-feature.md)

---

## 1) Setup Providers

Required:

1. GitHub repository with Actions enabled
2. GitHub CLI authenticated (`gh auth login`)
3. Claude Code CLI available locally (`bun add -g @anthropic-ai/claude-code`)
4. `jq` installed

Set GitHub secrets in the target repo:

```bash
bash scripts/setup-github-secrets.sh
```

The helper configures:

1. `CLAUDE_CODE_OAUTH_TOKEN`
2. `GH_READ_TOKEN`

---

## 2) Copy Orchestration Into Your Repo

From this repository, copy the orchestration files into your target repository preserving paths:

1. [orchestration-kit/.github/workflows/ai-agent-work.yml](orchestration-kit/.github/workflows/ai-agent-work.yml) -> `.github/workflows/ai-agent-work.yml`
2. [orchestration-kit/scripts/dispatch.sh](orchestration-kit/scripts/dispatch.sh) -> `scripts/dispatch.sh`
3. [orchestration-kit/scripts/dispatch-prompt.md](orchestration-kit/scripts/dispatch-prompt.md) -> `scripts/dispatch-prompt.md`
4. [orchestration-kit/scripts/worker-run.sh](orchestration-kit/scripts/worker-run.sh) -> `scripts/worker-run.sh`
5. [orchestration-kit/scripts/worker-prompt.md](orchestration-kit/scripts/worker-prompt.md) -> `scripts/worker-prompt.md`
6. [orchestration-kit/scripts/setup-github-secrets.sh](orchestration-kit/scripts/setup-github-secrets.sh) -> `scripts/setup-github-secrets.sh`
7. [orchestration-kit/scripts/ralph-once.sh](orchestration-kit/scripts/ralph-once.sh) -> `scripts/ralph-once.sh`
8. [orchestration-kit/scripts/ralph-loop.sh](orchestration-kit/scripts/ralph-loop.sh) -> `scripts/ralph-loop.sh`
9. [orchestration-kit/scripts/ralph-prompt.md](orchestration-kit/scripts/ralph-prompt.md) -> `scripts/ralph-prompt.md`

Minimum files required to run the orchestration system:

1. `.github/workflows/ai-agent-work.yml`
2. `scripts/dispatch.sh`
3. `scripts/dispatch-prompt.md`
4. `scripts/worker-run.sh`
5. `scripts/worker-prompt.md`
6. `scripts/setup-github-secrets.sh`
7. `scripts/ralph-once.sh`
8. `scripts/ralph-loop.sh`
9. `scripts/ralph-prompt.md`

Mark scripts executable:

```bash
chmod +x scripts/dispatch.sh scripts/worker-run.sh scripts/setup-github-secrets.sh scripts/ralph-once.sh scripts/ralph-loop.sh
```

---

## 3) Issue Contract (How You Feed the System)

Use issues with:

1. `AFK` or `HITL` marker
2. Acceptance criteria
3. Optional `Blocked by` list

Recommended body format:

```md
## Type
AFK

## Goal
Short statement of outcome

## Acceptance Criteria
- Criterion 1
- Criterion 2

## Blocked by
- #123

## Notes
Constraints and non-goals
```

---

## 4) Run the Orchestration Loop

There are two valid orchestration modes.

1. Dispatcher/Worker mode: issue-driven parallel execution on GitHub Actions.
2. RALPH mode: planning-driven local iterative execution until completion signal.

## 4.1 Dispatcher/Worker Mode

Dispatch batch:

```bash
bash scripts/dispatch.sh
```

Monitor:

```bash
gh run list --workflow=ai-agent-work.yml
```

What happens:

1. Dispatcher fetches open issues, in-progress runs, and open AI branches.
2. Orchestrator prompt selects actionable AFK tasks.
3. One workflow run is launched per selected task.
4. Worker creates a branch, implements task, commits, and emits PR metadata.
5. Workflow pushes branch and opens PR.

Note: The workflow installs repo dependencies only if `package.json` exists, so this setup remains app-agnostic for non-Node repositories.

## 4.2 RALPH Loop Mode

Single iteration:

```bash
bash scripts/ralph-once.sh
```

Repeated iterations:

```bash
bash scripts/ralph-loop.sh 10
```

Optional planning file override:

```bash
RALPH_CONTEXT_FILES='@plans/prd.md @plans/tasks.md @progress.txt' bash scripts/ralph-loop.sh 10
```

What happens:

1. Agent selects one highest-priority task from planning context.
2. Agent executes only that task, validates, updates progress artifacts, commits.
3. Loop repeats next iteration.
4. Loop exits early when agent emits `<promise>COMPLETE</promise>`.

---

## 5) Human Responsibilities

Your role is orchestration and review:

1. Keep issue specs clear and small.
2. Mark uncertain work as `HITL`.
3. Review AI PRs quickly.
4. Merge safe PRs.
5. Re-dispatch after merges to unlock dependencies.
6. For RALPH mode, keep planning/progress files current between iterations.

---

## 6) Recommended Guardrails

1. Require PR reviews before merge.
2. Enable branch protection on `main`.
3. Require CI checks for typecheck/tests in target repo.
4. Keep tasks small to reduce merge conflicts.
5. Use explicit completion criteria so the RALPH loop can terminate correctly.

---

## 7) Minimal Daily Runbook

1. Groom issues (`AFK`/`HITL`, blockers, acceptance criteria).
2. Run `bash scripts/dispatch.sh` for parallel issue execution.
3. Optionally run `bash scripts/ralph-loop.sh 10` for planning-driven iterative execution.
4. Review opened PRs from `ai/*` branches.
5. Merge, then run next orchestration cycle.

---

## 8) Optional Configuration (Models, Branches, Skills, Extra Context)

### Dispatcher overrides

Set at runtime when running `scripts/dispatch.sh`:

1. `WORKFLOW_FILE` (default: `ai-agent-work.yml`)
2. `TARGET_BRANCH` (default: `main`)
3. `BRANCH_PREFIX` (default: `ai`)
4. `ORCHESTRATOR_MODEL` (default: `sonnet`)

Example:

```bash
TARGET_BRANCH=develop BRANCH_PREFIX=agent ORCHESTRATOR_MODEL=sonnet bash scripts/dispatch.sh
```

### RALPH loop overrides

Set at runtime when running `scripts/ralph-once.sh` or `scripts/ralph-loop.sh`:

1. `RALPH_CONTEXT_FILES` (default: `@plans/prd.md @progress.txt`)
2. `RALPH_MODEL` (optional model override)
3. `RALPH_NOTIFY_CMD` (optional notification command used by `ralph-loop.sh`)

Example:

```bash
RALPH_CONTEXT_FILES='@plans/prd.md @plans/tasks.md @progress.txt @docs/ai-guidelines.md' RALPH_MODEL=sonnet bash scripts/ralph-loop.sh 10
```

### Adding skills or extra instructions

To transfer custom skills/instructions into another repo:

1. Copy your skill files (for example `.claude/skills/.../SKILL.md`) into the target repo.
2. Include those files in `RALPH_CONTEXT_FILES` so local RALPH iterations always see them.
3. For dispatcher/worker mode, encode durable rules in `scripts/dispatch-prompt.md` and `scripts/worker-prompt.md`.
4. Keep skill prompts app-agnostic unless they are intentionally repo-specific.

This is the reusable, app-independent process for AI-first orchestration from idea to shipped code.
