# AI Guide: Why This Process Works

Use `README.md` as the canonical setup and runbook.

This guide explains the architecture and reasoning behind that process so teams can adapt it intentionally.

## Core operating model

The orchestration kit splits work into three planes:

1. Planning plane: humans define goals, acceptance criteria, and constraints.
2. Execution plane: AI workers implement and validate scoped tasks.
3. Control plane: scripts/workflow prevent duplicated work and maintain flow.

This split keeps humans in high-leverage activities (idea generation, orchestration, architecture) while AI handles repetitive implementation labor.

## Why two execution modes exist

1. Dispatcher/worker mode is issue-driven and parallelized on GitHub Actions.
2. RALPH mode is planning-driven and iterative on local runtime.

Use dispatcher mode when independent tasks can run concurrently.
Use RALPH mode when sequencing and evolving plans matter more than throughput.

## Why issue shape is strict

The AFK/HITL + acceptance criteria + blockers contract exists to make task selection deterministic:

1. AFK/HITL decides autonomy level.
2. Acceptance criteria define completion boundaries.
3. Blockers allow dependency-aware scheduling.

Without this contract, dispatch quality drops and manual triage increases.

## Why preflight exists

Preflight checks catch setup drift before any run starts:

1. Missing binaries (`gh`, `jq`, `claude`, `git`)
2. Missing auth/session (`gh auth`)
3. Missing workflow file
4. Missing repository secrets

This avoids expensive failed workflow runs and reduces operator interruption.

## Why Claude starter config is included

The starter `.claude/settings.json` adds a safety hook that blocks destructive git operations from shell tool usage.

This guardrail is intentionally minimal:

1. It reduces catastrophic repo damage risk.
2. It does not slow normal implementation flow.
3. It keeps autonomy high while preserving reviewability.

## Why planning templates are installed

The default `plans/prd.md`, `plans/tasks.md`, and `progress.txt` reduce blank-page overhead and make RALPH loops immediately usable.

Templates are scaffolding, not policy. Teams should customize once and keep the structure stable.

## Recommended governance controls

1. Branch protection on the default branch.
2. Required PR review before merge.
3. Required CI checks for changed code.
4. Small AFK tasks to reduce merge conflicts.
5. Explicit completion criteria to make `<promise>COMPLETE</promise>` meaningful.

## Process anti-patterns

1. Large, vague issues sent as AFK.
2. Mixing architecture decisions into implementation tasks.
3. Running loops without review gates.
4. Treating AI output as unreviewed truth.

## Adapting to your repo

Tune only what changes behavior safely:

1. Prompt contracts in `scripts/dispatch-prompt.md`, `scripts/worker-prompt.md`, and `scripts/ralph-prompt.md`
2. Runtime env overrides (`WORKFLOW_FILE`, `TARGET_BRANCH`, `BRANCH_PREFIX`, `ORCHESTRATOR_MODEL`, `RALPH_CONTEXT_FILES`, `RALPH_MODEL`, `RALPH_NOTIFY_CMD`)
3. Custom skills in `.claude/skills/...` included through loop context files

Keep the orchestration interfaces stable to preserve portability across repositories.
