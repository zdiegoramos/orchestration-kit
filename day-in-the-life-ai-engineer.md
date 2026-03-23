# Day In The Life: AI Engineer Building Revenue Apps With Agents

## 06:45 - Revenue First, Not Code First

The day starts with one question: what ships today that can move revenue?

The AI engineer opens the dashboard and sees three commercial signals:

- 2 enterprise trial accounts stalled at onboarding
- 14% drop-off on "Create First Workflow"
- A support queue full of "retry failed" complaints

He writes one instruction to his planning agent:

"Prioritize one vertical slice that increases activation this week and one that reduces workflow failure refunds."

Within minutes, the agent proposes two slices:

1. Self-serve onboarding checklist for trial admins
2. Durable retry + status visibility for background workflow execution

Both are accepted because both tie directly to money: better activation and lower churn/refund risk.

## 07:30 - Product Intent Becomes Executable Work

He does not manually break down tasks.

A PRD-to-plan agent converts intent into thin, end-to-end slices with acceptance criteria and eval criteria. Every slice must include:

- contract updates in oRPC
- workflow behavior in Effect
- UI path in Next.js/shadcn
- tests and eval checks in CI

He rejects any plan that is "backend-only" or "UI-only." If it cannot be demoed end to end, it is not a slice.

## 08:30 - Contract Before Implementation

He asks the API agent to propose oRPC contract changes first.

The agent drafts:

- CreateOnboardingChecklist command
- GetWorkflowRunStatus query
- RetryWorkflowRun command with idempotency key requirement

The engineer reviews contracts like a product person, not a syntax editor:

- Is the response useful to the UI?
- Can support teams answer customer questions from this payload?
- Are error shapes explicit enough to power user-facing messages?

Only after contracts are approved does implementation start.

## 09:30 - Effect Owns Reliability

The workflow agent writes Effect programs for retry-heavy operations.

Design rules are strict:

- route handlers stay thin
- retries, backoff, and timeout live in Effect workflows
- every retryable command requires idempotency key
- all failures map to a standard API error envelope

He checks traces, not just tests. If a workflow succeeds but hides partial failure risk, it is not done.

## 10:45 - Frontend Velocity Without Chaos

Frontend is the bottleneck, so he optimizes generation constraints.

He uses a UI agent with a locked template catalog:

- onboarding checklist pattern
- async status panel pattern
- empty/loading/error states pattern

Because oRPC clients are generated, there is almost no hand-written request code. The UI focuses on conversion copy, state transitions, and speed.

He A/B tests two checklist variants in preview environments before lunch.

## 12:00 - PR Environments As Decision Engines

Every PR automatically gets:

- preview app
- branch Postgres database on Neon
- seeded realistic tenant data
- visual regression run
- contract tests
- eval score report

He does not merge based on intuition. He merges based on evidence.

If the onboarding variant improves completion in synthetic eval and passes guardrails, it moves forward.

## 13:30 - Human Review Where It Matters

He does not review everything manually.

Review budget is spent on high-risk surfaces:

- billing impacts
- auth boundaries
- destructive operations
- workflow compensation logic

For auth specifically, the team follows a fixed policy:

- Better-Auth is the default implementation.
- Identity core data (users, sessions, auth events) stays self-owned in first-party storage.
- Only peripheral auth infrastructure is outsourced through replaceable adapters.

Lower-risk UI styling diffs are auto-approved when eval and quality gates pass.

This is how one engineer scales output without scaling incidents.

## 14:30 - Observability Is Part Of Shipping

Before merge, the observability agent verifies:

- trace spans exist for each workflow stage
- structured logs include tenant, workflowRunId, retryCount
- dashboards can answer: "Why did this customer fail?"

He refuses to ship "black-box" features. Unobservable code is future churn.

## 15:30 - Merge With Guardrails

Branch protection requires:

- typecheck
- Biome
- contract tests
- happy-path e2e
- eval threshold pass

If one fails, the fix agent gets a targeted prompt with failing evidence. No guessing loops.

When green, merge happens with artifact links:

- prompt used
- diff summary
- eval score
- test evidence
- rollout note

## 16:00 - Revenue Feedback Loop

Deployment is not the end.

A post-release agent watches:

- onboarding completion rate
- workflow retry success rate
- support ticket volume for failed runs
- expansion signals from larger accounts

Today’s outcome:

- onboarding completion +9.4%
- failed workflow support tickets -31%
- one enterprise prospect moved to security review because workflow reliability evidence was clear

That is the real job: turning product intent into reliable revenue motion.

## 17:30 - What This Engineer Actually "Codes"

He still writes code, but rarely by hand from scratch.

His core work is:

- defining intent with precision
- designing contracts and boundaries
- enforcing reliability policies
- choosing what gets autonomy and what gets human oversight
- tightening eval loops so quality compounds every week

In this model, determinism is not abandoned.

It is relocated:

- deterministic guardrails
- deterministic quality gates
- deterministic rollback paths

inside a probabilistic generation engine.

That is how AI agents become a production force, not a demo tool.
