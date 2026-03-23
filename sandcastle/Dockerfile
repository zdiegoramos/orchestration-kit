FROM node:22-bookworm

# Install system dependencies required by common coding workflows.
RUN apt-get update && apt-get install -y \
    git \
    curl \
    jq \
    && rm -rf /var/lib/apt/lists/*

# Enable corepack so pnpm/yarn are available.
RUN corepack enable

# Install GitHub CLI.
RUN curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg \
    | dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" \
    | tee /etc/apt/sources.list.d/github-cli.list > /dev/null \
    && apt-get update && apt-get install -y gh \
    && rm -rf /var/lib/apt/lists/*

# Run agent processes as non-root.
RUN useradd -m -s /bin/bash agent
USER agent

# Install Claude Code CLI for the agent user.
RUN curl -fsSL https://claude.ai/install.sh | bash

ENV PATH="/home/agent/.local/bin:$PATH"

# Workspace mount target used by sandbox tooling.
RUN mkdir -p /home/agent/repos

WORKDIR /home/agent
ENTRYPOINT ["sleep", "infinity"]
