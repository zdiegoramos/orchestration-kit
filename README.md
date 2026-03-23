# AI Orchestration Kit

This kit is opinionated for one workflow only: PRD-first, interview-driven planning, then sandboxed autonomous execution.

## Canonical flow

Use this exact sequence:

1. User starts Claude in terminal.
2. User runs `/grill-me` with initial intent.
3. AI asks clarifying and design questions until the scope is clear.
4. User runs `/write-a-prd` to create the parent PRD issue.
5. User runs `/prd-to-plan` to produce a phased vertical-slice plan.
6. User runs `/prd-to-issues` to generate implementation issues from the PRD.
7. User runs the Ralph loop in the sandbox to execute one task per iteration.
8. User asks AI to create a QA issue on GitHub for verification/review.
9. Repeat from step 2 or 4 as new intent arrives.

```mermaid
flowchart TD
  A[Start Claude] --> B[/grill-me with intent]
  B --> C[AI interviews until clear]
  C --> D[/write-a-prd]
  D --> E[/prd-to-plan]
  E --> F[/prd-to-issues]
  F --> G[Run sandboxed Ralph loop]
  G --> H[Create QA issue]
  H --> I[Repeat]
```

## One-time setup

1. Install GitHub CLI and authenticate (`gh auth login`).
2. Install Claude Code CLI.
3. Install `jq`.
4. Install Docker Desktop and ensure it is running.

Quick check:

```bash
gh --version && claude --version && jq --version && docker --version
```

Install into a target repository:

```bash
bash orchestration-kit/scripts/install-into-target.sh /absolute/path/to/target-repo
```

Then in the target repo:

```bash
bash scripts/preflight-check.sh
bash scripts/sandbox-setup.sh
```

## Daily operating loop

From the target repository root:

1. Do discovery in Claude:

```text
/grill-me <your intent>
```

2. Generate and align on PRD:

```text
/write-a-prd
```

3. Generate implementation plan:

```text
/prd-to-plan
```

4. Generate implementation issues:

```text
/prd-to-issues
```

5. Execute in sandbox:

```bash
bash scripts/sandbox-loop.sh 10
```

6. Create QA issue after output is ready:

```bash
gh issue create \
  --title "QA: <feature name>" \
  --body "Verify behavior, test edge cases, and report gaps for PRD #<number>."
```

## Parallel PRDs (optional)

The kit supports running multiple PRDs at the same time by isolating each PRD into a track.

1. Create a track:

```bash
bash scripts/start-prd-track.sh <track-slug> <parent-prd-issue-number>
```

2. Keep each terminal pinned to one track and one PRD.
3. For issue execution, scope sandbox loop to that PRD:

```bash
RALPH_PARENT_PRD=<parent-prd-issue-number> bash scripts/sandbox-loop.sh 10
```

4. For plan-driven local loop, point context files at the track:

```bash
RALPH_CONTEXT_FILES='@plans/tracks/<track-slug>/prd.md @plans/tracks/<track-slug>/plan.md @plans/tracks/<track-slug>/progress.txt' bash scripts/ralph-loop.sh 10
```

This avoids cross-talk between concurrent initiatives and keeps each loop deterministic.

## Core scripts in this workflow

1. `scripts/preflight-check.sh`
2. `scripts/sandbox-setup.sh`
3. `scripts/sandbox-once.sh`
4. `scripts/sandbox-loop.sh`
5. `scripts/sandbox-cleanup.sh`
6. `scripts/ralph-once.sh`
7. `scripts/ralph-loop.sh`
8. `scripts/start-prd-track.sh`

## Deep dive

See `ai-guide.md` for design rationale and operating guardrails.
