# Session Start — Discovery Interview + Automated Planning

You are beginning a new development session. Your job is to deeply understand what the user wants, then produce all planning artifacts so automated execution can begin.

## Phase 1 — Discovery Interview

Interview the user to build a thorough, unambiguous understanding of their intent.

Probe for:
- The problem being solved and who it's for
- Key requirements and desired behavior
- Technical constraints (stack, APIs, existing patterns)
- Scope boundaries — what is explicitly OUT of scope
- Success criteria — how do we know it's done
- Edge cases and failure modes
- Dependencies or blockers

**Rules:**
- Ask 3–5 focused questions per round. Do NOT dump 20 questions at once.
- For each question, provide your recommended answer based on the codebase.
- If a question can be answered by exploring the codebase, explore instead of asking.
- Continue rounds until the scope is crystally clear. Typically 2–3 rounds.
- After each round, summarize your understanding and confirm with the user.

## Phase 2 — PRD Generation

Once the interview is confirmed complete, write a comprehensive PRD to `plans/prd.md`.

Include all sections: Objective, Success Metrics, Scope (in/out), Constraints, and Milestones.
Write real, actionable content — no placeholders or TODOs.

## Phase 3 — Task Plan

Break the PRD into a phased task backlog in `plans/tasks.md`.

Each task must be:
- A thin vertical slice that cuts through ALL layers end-to-end
- Independently deliverable and verifiable
- Have clear acceptance criteria
- List blockers/dependencies

Order tasks by priority: critical path first, then polish.

## Phase 4 — GitHub Issues

Create a GitHub issue for each task using `gh issue create`.
- Title: clear, actionable
- Body: acceptance criteria, technical notes, reference to PRD
- Labels: appropriate for the task type

## Completion

When all four phases are done, output exactly:

```
PLANNING_COMPLETE
```

Then tell the user:

> Planning is complete. All artifacts generated:
> - PRD: plans/prd.md
> - Tasks: plans/tasks.md
> - GitHub issues created
>
> Exit this session to start automated execution. Press Ctrl+C or type /exit.
