# The AI Engineer Process

A concise, low-intervention process to go from idea to revenue with AI doing almost all implementation work.

## Operating Principle

- AI does all research, planning, coding, testing, refactoring, docs, and release automation.
- Human intervenes only for irreversible or external-authority actions (billing, legal, secrets, production approvals).

## Step 1: Define Revenue Target (Human: 15-20 min)

Provide AI:
- Target customer
- Pain solved
- Pricing model (subscription, usage, one-time)
- 30-day revenue target

If unknown, ask AI to generate 3 business model options and pick 1.

## Step 2: Create PRD and Plan (AI-led)

AI actions:
- Run a PRD interview (problem, users, scope, out-of-scope).
- Convert PRD into vertical slices (end-to-end tracer bullets).
- Produce a phased plan with acceptance criteria per slice.

Human actions:
- Approve PRD and slice order once.

Exit criteria:
- A single source PRD exists.
- A phase plan exists where each phase is independently demoable.

## Step 3: Scaffold the Stack (AI-led)

AI actions:
- Scaffold Next.js + TypeScript strict mode + Bun.
- Add shadcn/ui + CVA, Better Auth, oRPC, Effect, drizzle-orm, Neon/Postgres wiring.
- Configure Biome + Ultracite, test setup, CI gates.
- Create environment-variable templates and startup scripts.

Human actions (only if needed):
- Provide external account IDs and API keys (GitHub, Neon, auth providers, payment providers).

Exit criteria:
- Fresh clone can install, typecheck, lint, test, and boot locally.

## Step 4: Build One Slice at a Time (AI-led TDD loop)

For each slice:
1. AI writes one failing behavior test (RED).
2. AI writes minimal code to pass (GREEN).
3. AI refactors safely (REFACTOR).
4. AI updates docs/changelog and opens PR.

Rules:
- No horizontal implementation batches.
- Tests assert public behavior and contracts, not internals.
- Keep modules deep: small interfaces, rich internals.

Human actions:
- Review/approve only high-risk changes (auth, payments, data deletion, privilege boundaries).

## Step 5: Enforce Guardrails (AI-led)

AI actions:
- Enforce CI policy: typecheck, lint, unit/contract/integration/e2e tests.
- Block risky auth diffs without explicit reviewer approval.
- Run eval checks on agent-generated changes before merge.
- Keep dangerous git operations blocked by hooks.

Human actions:
- Final approval for policy-blocked merges.

## Step 6: Production Release (AI-led with human key handoff)

AI actions:
- Prepare migrations, release notes, rollback steps, and deploy commands.
- Run pre-release verification and smoke tests.
- Execute deployment workflow.

Human actions:
- Inject production secrets (or approve secret manager access).
- Approve first production deploy.

Exit criteria:
- App deployed.
- Rollback path tested.
- Basic SLO monitoring active.

## Step 7: Revenue Instrumentation (AI-led)

AI actions:
- Add event tracking for activation, conversion, churn signals.
- Build dashboard for: trial starts, paid conversions, MRR, churn, CAC proxy.
- Create weekly experiment loop (pricing, onboarding, retention).

Human actions:
- Approve pricing and customer-facing messaging.

## Step 8: Weekly Autonomous Operating Cadence

AI runs this cadence every week:
1. Analyze funnel drop-offs and support feedback.
2. Propose top 3 revenue-impact changes.
3. Implement highest-impact slice with tests and guardrails.
4. Ship, measure for 3-7 days, and report deltas.

Human decides only:
- Which of top 3 to prioritize.
- Any legal/compliance-sensitive change.

## Human-Only Action Checklist

Only do these yourself:
- Create/verify billing accounts and payment rails.
- Provide or approve access to secrets and production credentials.
- Approve legal/compliance text (ToS, Privacy, regulated flows).
- Approve high-risk production changes (auth, payments, destructive migrations).

Everything else is delegated to AI.

## Definition of Done

The process is working when:
- AI can take a new slice from brief -> PR -> merged -> deployed with no manual code edits.
- Human involvement is limited to approvals, keys, and business decisions.
- Revenue metrics are automatically tracked and reviewed every week.
