PROMPT START

Implement a QA Feedback to GitHub Issues feature designed for autonomous resolution by the RALPH loop.

Goal
Build a send feedback flow so a developer doing QA can submit feedback from inside the app, and the app creates a GitHub issue formatted for RALPH-compatible execution.

Context

Repository owner/name: REPO_OWNER/REPO_NAME
Default labels to apply: qa-feedback, afk
The resulting issue body must follow the AFK/HITL + acceptance criteria + blockers format so orchestration can pick it up.
Prefer existing UI patterns/components and current app architecture.
Requirements

UI Entry Point
Add a visible “Send Feedback” action in the app shell/header.
Open a modal or panel with:
Description textarea (required)
Optional “Expected behavior”
Optional “Actual behavior”
Optional “Severity” (low/medium/high)
Optional “Add more after submit” checkbox
Include keyboard submit shortcut: Cmd/Ctrl + Enter.
Capture current route/page automatically.
API Endpoint
Create a server endpoint that receives feedback payload and validates required fields.
Endpoint must create a GitHub issue in REPO_OWNER/REPO_NAME.
Use server-side auth (token from environment), never expose token to client.
Return success payload including issue number and URL.
RALPH-Compatible Issue Formatting
Construct issue body with this exact structure:
Section: Type

Default to AFK unless user explicitly flags “Needs discussion”, then HITL.
Section: Goal

Summarize requested outcome in 1-2 lines.
Section: Acceptance Criteria

Convert feedback into concrete bullets.
Include at least 3 criteria when possible.
Make criteria testable and implementation-oriented.
Section: Blocked by

Default to “None”.
If user referenced dependency/blocked context, list it.
Section: Notes

Include:
Submitted from route/path
Severity
Expected vs actual (if provided)
Timestamp
Reporter identity if available
Add “QA feedback source” marker.
Title Generation
Generate a concise issue title from description (max 80 chars).
If AI title generation fails, use deterministic fallback from first sentence/truncated text.
Labels and Metadata
Apply labels qa-feedback and afk by default.
If Type is HITL, use hitl label instead of afk.
Optionally add severity label if your repo supports it.
UX Behavior
Show success toast with issue number/link.
Show clear error toast on failure.
If “Add more after submit” is enabled, reset form and keep modal open.
Otherwise close modal after successful submit.
Security and Reliability
Validate all incoming fields server-side.
Sanitize/trim text inputs.
Add robust error handling for GitHub API failures/rate limits.
Log failures with actionable context.
Tests
Add tests for:
Endpoint validation failures
Correct issue body formatting (AFK/HITL sections included)
Label selection logic
Fallback title generation behavior
Success/error response handling
Configuration
Add required environment variables to env example and docs:
GITHUB_TOKEN_FOR_FEEDBACK
GITHUB_FEEDBACK_REPO (optional override)
Document setup steps for token scope and usage.
Deliverables
Implement feature end-to-end.
Provide a concise change summary.
List exact files changed.
Include a short manual QA checklist.
Non-goals

Do not implement unrelated product features.
Keep changes focused on feedback-to-issue flow.
PROMPT END

