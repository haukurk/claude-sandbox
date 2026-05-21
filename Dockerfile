FROM node:22-bookworm-slim

ARG CLAUDE_CODE_VERSION=latest

RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    curl \
    jq \
    ripgrep \
    fd-find \
    build-essential \
    python3 \
    ca-certificates \
    openssh-client \
    && rm -rf /var/lib/apt/lists/*

RUN npm install -g "@anthropic-ai/claude-code@${CLAUDE_CODE_VERSION}"

RUN useradd -m -s /bin/bash claude
USER claude
WORKDIR /home/claude/repo

ENTRYPOINT ["claude", "--dangerously-skip-permissions"]
