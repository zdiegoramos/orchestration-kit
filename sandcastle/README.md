# Sandcastle Profile (Sandboxed RALPH)

This folder is a portable sandbox profile for autonomous RALPH work.

## What it is

The sandbox model is:

1. Run Claude with broad edit permissions (`acceptEdits`) inside a Docker sandbox.
2. Keep that power scoped to an isolated runtime (filesystem/process boundary).
3. Mount your real repository into the sandbox so normal git operations still write commits in your repo history.

In other words: high agent capability in a constrained runtime, while preserving standard git traceability.

## Files

1. `Dockerfile`: sandbox image used by `docker sandbox run -t ...`
2. `config.json`: profile-level iteration defaults
3. `prompt.md`: the RALPH loop contract/instructions
4. `.env.example`: required token names
5. `.gitignore`: prevents accidental secret commits

## Security model

1. The agent process runs as non-root user `agent`.
2. Tooling is preinstalled in the image (`git`, `gh`, `jq`, Claude CLI).
3. Secrets are provided at runtime via local `.env`, not committed files.
4. Resulting commits are ordinary git commits in your mounted repository.

## Important limitation

This sandbox is an execution boundary, not a policy engine. If the prompt allows broad actions, the agent can still make broad changes within the mounted repo. Use branch protection, review gates, and CI checks as your final safety controls.
