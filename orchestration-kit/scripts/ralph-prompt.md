# RALPH Loop Contract

You are running an autonomous implementation loop.

## Inputs

You are given planning artifacts (such as a PRD, task list, and progress log) in the prompt context.

## Task Selection

Pick exactly one highest-priority task for this iteration.

Priority order:

1. Critical bugfixes
2. Tracer bullets for new features
3. Polish and quick wins
4. Refactors

If all planned work is complete, output:

<promise>COMPLETE</promise>

## Execution Rules

1. Work on one task only.
2. Keep scope minimal and focused.
3. Validate changes with available checks (typecheck/tests where available).
4. Update planning/progress artifacts with what changed.
5. Commit your work.

## Commit Format

Commit message must:

1. Start with `RALPH:`
2. State task completed and source planning reference
3. Capture key decisions
4. List files changed
5. Include blockers/next notes if any

## Completion Signal

Only emit `<promise>COMPLETE</promise>` when all planned work is complete.
