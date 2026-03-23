# AI Guide: Why This Process Works

Use `README.md` as the runbook. This document explains why the PRD-first loop is the only recommended operating model for this kit.

## Core model

The workflow has three explicit phases:

1. Discovery phase: `/grill-me` converges on intent and constraints.
2. Design phase: `/write-a-prd`, `/prd-to-plan`, and `/prd-to-issues` convert intent into executable slices.
3. Execution phase: sandboxed Ralph loops implement one issue at a time with commit traceability.

This keeps architecture decisions human-guided, while implementation remains autonomous and iterative.

## Why interview first

Starting with `/grill-me` reduces ambiguity before writing artifacts. When ambiguity is resolved up front:

1. PRDs are smaller and more stable.
2. Plans have fewer late structural changes.
3. Implementation issues are less likely to overlap or conflict.

## Why PRD -> plan -> issues

This sequence enforces a strict decomposition order:

1. PRD defines user outcomes and boundaries.
2. Plan defines phased tracer-bullet slices.
3. Issues define independently executable tasks.

Skipping this order usually causes vague tasks, hidden dependencies, and loop thrash.

## Why sandboxed Ralph loops

The sandbox loop is the execution engine because it balances autonomy and safety:

1. Agent has high edit capability in an isolated runtime.
2. Real repository history still captures every commit.
3. One-task-per-iteration behavior keeps review and rollback practical.

## Why QA issues are part of the loop

A dedicated QA issue after implementation creates a feedback checkpoint between build and trust:

1. Verification work is explicit and trackable.
2. Regressions are logged as new scoped work, not hidden in chat.
3. The next iteration starts from concrete failures, not assumptions.

## Parallel PRDs without chaos

Multiple PRDs can run concurrently when each has a separate track and a scoped execution loop.

Rules:

1. One parent PRD issue per track.
2. One terminal per active track.
3. Scope sandbox issue selection by parent PRD (`RALPH_PARENT_PRD`).
4. Scope local planning context by track files (`RALPH_CONTEXT_FILES`).

If these boundaries are not enforced, tasks leak across initiatives and velocity drops.

## Guardrails

Keep these controls in place:

1. Branch protection and required review.
2. Required CI for merged branches.
3. Small vertical slices with explicit acceptance criteria.
4. Preflight before runs to catch environment drift.

## Anti-patterns this kit avoids

1. Issue-first coding without discovery.
2. Massive PRDs with no phased plan.
3. Unscoped autonomous loops across unrelated work.
4. Treating implementation output as complete without QA feedback.
