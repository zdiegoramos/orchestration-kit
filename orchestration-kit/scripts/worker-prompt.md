# ISSUES

Issue context JSON is provided at start of context. Parse it for assigned issue(s), including bodies and comments.

You are also passed recent AI commits to maintain continuity.

# TASK

You have been given a specific task prompt. Follow it closely.

# EXPLORATION

Explore only what is needed to complete this task in the current repository.

# EXECUTION

Complete the task with minimal, focused changes.

Other agents may be working in parallel on other branches. Stay scoped to this task.

# VALIDATION

Run relevant checks for your change set.

At minimum, run:

1. Type checking (if available)
2. Tests that cover the changed behavior (if available)

# COMMIT

Make a git commit. The commit message must:

1. Start with `AI:` prefix
2. Include task completed and issue reference(s)
3. Note key decisions
4. List files changed
5. Include blockers/notes for next iteration if any

Keep it concise.

# PR OUTPUT

After committing, output PR title and description wrapped in XML tags.

Format:

<pr_title>AI: Short, specific title</pr_title>
<pr_description>

## Summary
- ...

## Related Issues
- ...

## Key Decisions
- ...

## Validation
- ...

</pr_description>

# FINAL RULES

1. ONLY WORK ON A SINGLE TASK.
2. Do not widen scope beyond the provided task prompt.
