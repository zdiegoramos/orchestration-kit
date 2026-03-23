# AI Agent Stack Setup Guide

A low-friction setup where the human only does actions AI cannot do safely (accounts, secrets, approvals). Everything else is delegated to AI with copy-paste command prompts.

## Outcome

By the end of this guide, you will have:

- A Next.js + TypeScript app
- oRPC contract layer
- Effect-powered backend workflow module
- Drizzle + Postgres setup (Neon-ready)
- Biome + tests + CI guardrails
- Preview-ready workflow foundation for branch environments

Estimated time: 35 to 60 minutes.

---

## Step 0: Human-Only Actions (Required)

These steps cannot be delegated safely to AI.

1. Create or confirm accounts:
- GitHub account
- Neon account
- Vercel account (or your chosen preview-hosting platform)

2. Install local tools:
- Git
- Node.js LTS (22.x recommended)
- bun
- GitHub CLI
- VS Code

3. Generate GitHub personal access token:
- GitHub -> Settings -> Developer settings -> Personal access tokens -> Fine-grained tokens
- Grant repo access for the target org/repo
- Save token in a password manager

4. Authenticate GitHub CLI locally:
~~~bash
gh auth login
~~~

5. Create a Neon project and copy:
- Database URL
- Pooled database URL (if provided)

6. Create initial environment secrets in your password manager:
- DATABASE_URL
- BETTER_AUTH_SECRET
- BETTER_AUTH_URL (if required by your Better-Auth setup)
- NEXTAUTH_SECRET (if used)
- SENTRY_DSN (optional but recommended)

7. Open an empty folder in VS Code for the new app.

---

## Step 1: Tell AI To Scaffold The App

Paste this message to your AI agent:

~~~text
Create a production-ready baseline in this folder using:
- Next.js (App Router) + TypeScript
- Tailwind + shadcn
- Biome
- Vitest + Playwright
- Drizzle ORM
- oRPC base contract and client wiring
- Effect.ts base module for workflow orchestration

Requirements:
1) Use bun.
2) Create scripts for dev, build, test, typecheck, lint, format, db:generate, db:migrate.
3) Add a clean folder architecture:
   - src/app
   - src/modules
   - src/contracts
   - src/workflows
   - src/infrastructure
4) Add one sample vertical slice end to end:
   - oRPC route
   - Effect service
   - DB call through Drizzle
   - UI page consuming it
5) Add README setup instructions.
6) Run install + typecheck + tests, and fix any failures.
~~~

Expected result:
- Working local app with one complete contract-to-UI slice.

---

## Step 2: Add Environment And Database Wiring

After scaffold completes, create a .env.local with your real values.

Then paste this to your AI agent:

~~~text
Set up environment management and database bootstrap:
1) Add typed env validation at startup.
2) Read DATABASE_URL from .env.local.
3) Add Drizzle config and first migration.
4) Create a health table and seed script.
5) Run db generate + db migrate + seed.
6) Verify app can read/write the health table.
7) Document exact commands in README.
~~~

Expected result:
- Database connected and verified with repeatable migration flow.

---

## Step 3: Add Authentication Boundary

Paste this to your AI agent:

~~~text
Integrate authentication with a clean boundary:
1) Add Better-Auth as the auth provider.
2) Create auth module interface used by application code.
3) Keep provider-specific code in infrastructure layer only.
4) Keep identity core data self-owned (users, sessions, auth events) in your database.
5) Outsource only peripheral auth infrastructure (email/SMS delivery, CAPTCHA, enterprise SSO bridge) behind adapters.
6) Add middleware/session guard for protected routes.
7) Add one protected demo page and one public page.
8) Add tests for auth guard behavior.
~~~

Expected result:
- Auth works now and remains replaceable later for enterprise SSO.

---

## Step 4: Add Effect Workflow Reliability Pattern

Paste this to your AI agent:

~~~text
Implement a durable workflow pattern using Effect:
1) Create a workflow module with retry policy, timeout, and structured error model.
2) Enforce idempotency key for retryable command.
3) Add workflow run table (status, attempts, lastError, timestamps).
4) Expose status query via oRPC.
5) Add tests for:
   - retry success after transient failure
   - idempotent duplicate submission
   - timeout handling
6) Add telemetry fields to logs: tenantId, workflowRunId, retryCount.
~~~

Expected result:
- Production-grade retry behavior and visibility for long-running jobs.

---

## Step 5: Add CI Guardrails For Agentic Development

Paste this to your AI agent:

~~~text
Set up CI and branch protections for AI-generated code quality:
1) Add GitHub Actions workflow running:
   - install
   - typecheck
   - lint
   - unit tests
   - e2e smoke tests
2) Add contract test job for oRPC boundaries.
3) Add PR comment summary with pass/fail status.
4) Add required status checks list in README for branch protection setup.
5) Add a rollback section in README with release safety steps.
~~~

Expected result:
- Every PR gets deterministic quality gates before merge.

---

## Step 6: Enable PR Preview Workflow

Human-only prep:
- Connect repository to Vercel (or equivalent)
- Add project env vars in hosting platform

Then paste this to your AI agent:

~~~text
Prepare preview environment support:
1) Add deployment docs for preview URLs per PR.
2) Add script to seed preview environments safely.
3) Add a preview smoke-test command.
4) Ensure app startup fails fast with clear errors if env vars are missing.
5) Update README with troubleshooting section for preview failures.
~~~

Expected result:
- Preview deploys are reproducible and debuggable.

---

## Step 7: Add Frontend Speed System

Paste this to your AI agent:

~~~text
Optimize frontend iteration speed:
1) Create reusable UI template generator docs for forms, tables, and async states.
2) Add component conventions for shadcn + CVA variants.
3) Add visual regression test setup for key pages.
4) Add one showcase page demonstrating approved UI patterns.
5) Add contribution guide so AI and humans follow same conventions.
~~~

Expected result:
- Faster UI shipping with less inconsistency and less rework.

---

## Step 8: Daily Operating Commands For AI

Use these as your daily prompts.

### A) Start-of-day planning
~~~text
Review open issues and yesterday's merged PRs. Propose 3 thin vertical slices for today ranked by revenue impact and risk reduction. For each, include acceptance criteria and test strategy.
~~~

### B) Build one slice end to end
~~~text
Implement slice #1 fully across oRPC contract, Effect application service, Drizzle data path, and UI. Write tests first for observable behavior. Keep route handlers thin and retries inside Effect workflows.
~~~

### C) Pre-merge hardening
~~~text
Run all quality gates. If anything fails, fix and rerun. Summarize risks, telemetry coverage, and rollback steps before merge.
~~~

### D) Post-release review
~~~text
Analyze production signals for the new feature. Report activation impact, failure rates, and support-facing error trends. Suggest one improvement slice.
~~~

---

## Human Approval Checkpoints

The human should approve only these moments:

1. New secret/provider onboarding
2. Billing-impacting behavior changes
3. Auth boundary changes
4. Destructive data migrations
5. Policy exceptions in CI/guardrails

Everything else can be delegated to AI under tests + guardrails.

---

## First-Week Rollout Plan

Day 1:
- Complete Steps 0 to 3

Day 2:
- Complete Step 4 and Step 5

Day 3:
- Complete Step 6 and Step 7

Day 4 to 5:
- Run Step 8 daily loop
- Ship first revenue-relevant vertical slice

---

## Smooth Onboarding Tips

- Keep one source of truth in README for setup, scripts, and troubleshooting.
- Require every agent-generated PR to include test evidence and risk notes.
- Prefer small slices merged fast over large batched changes.
- If a generated change is hard to explain, reject and regenerate with tighter constraints.

This is how the developer experience stays simple while reliability stays high.
