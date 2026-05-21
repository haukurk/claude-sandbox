FROM node:22-bookworm-slim

ARG CLAUDE_CODE_VERSION=latest

RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    curl \
    wget \
    jq \
    ripgrep \
    fd-find \
    build-essential \
    python3 \
    python3-pip \
    python3-venv \
    ca-certificates \
    openssh-client \
    # Networking
    nmap \
    netcat-openbsd \
    dnsutils \
    iputils-ping \
    traceroute \
    host \
    whois \
    iproute2 \
    tcpdump \
    socat \
    # Common tools
    unzip \
    zip \
    tar \
    gzip \
    less \
    vim-tiny \
    tree \
    file \
    procps \
    htop \
    strace \
    && rm -rf /var/lib/apt/lists/*

RUN npm install -g "@anthropic-ai/claude-code@${CLAUDE_CODE_VERSION}"

RUN useradd -m -s /bin/bash claude

COPY --chmod=755 entrypoint.sh /usr/local/bin/entrypoint.sh
COPY --chmod=755 statusline.sh /usr/local/bin/statusline.sh

USER claude
WORKDIR /home/claude/repo

ENTRYPOINT ["entrypoint.sh"]
