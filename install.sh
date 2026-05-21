#!/usr/bin/env bash
#
# Install claude-sandbox.
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/haukurk/claude-sandbox/main/install.sh | bash
#   or: ./install.sh [install-dir]
#
set -euo pipefail

REPO="haukurk/claude-sandbox"
BRANCH="main"
INSTALL_DIR="${CLAUDE_SANDBOX_INSTALL_DIR:-${1:-${HOME}/.claude-sandbox}}"
BIN_DIR="${CLAUDE_SANDBOX_BIN_DIR:-/usr/local/bin}"

RED='\033[0;31m'
GREEN='\033[0;32m'
BOLD='\033[1m'
DIM='\033[2m'
RESET='\033[0m'

log()   { echo -e "${GREEN}▸${RESET} $*"; }
error() { echo -e "${RED}✖${RESET} $*" >&2; exit 1; }

# Check deps
command -v docker &>/dev/null || error "Docker is required. Install it first: https://docs.docker.com/get-docker/"
command -v git &>/dev/null    || error "Git is required."

echo ""
echo -e "${BOLD}claude-sandbox${RESET} installer"
echo -e "${DIM}Run Claude Code off-leash — safely.${RESET}"
echo ""

# Clone or update
if [[ -d "$INSTALL_DIR/.git" ]]; then
    log "Updating existing installation..."
    git -C "$INSTALL_DIR" pull --ff-only origin "$BRANCH"
else
    if [[ -d "$INSTALL_DIR" ]]; then
        rm -rf "$INSTALL_DIR"
    fi
    log "Cloning ${REPO}..."
    git clone --depth 1 -b "$BRANCH" "https://github.com/${REPO}.git" "$INSTALL_DIR"
fi

chmod +x "${INSTALL_DIR}/claude-sandbox"

# Symlink to PATH
if [[ -w "$BIN_DIR" ]]; then
    ln -sf "${INSTALL_DIR}/claude-sandbox" "${BIN_DIR}/claude-sandbox"
elif command -v sudo &>/dev/null; then
    log "Linking to ${BIN_DIR} (requires sudo)..."
    sudo ln -sf "${INSTALL_DIR}/claude-sandbox" "${BIN_DIR}/claude-sandbox"
else
    warn "Could not link to ${BIN_DIR}. Add ${INSTALL_DIR} to your PATH:"
    echo "  export PATH=\"${INSTALL_DIR}:\$PATH\""
fi

# Build the Docker image
log "Building Docker image..."
docker build -t claude-sandbox:latest "$INSTALL_DIR"

echo ""
log "${BOLD}Installed!${RESET}"
echo ""
echo -e "  Run ${BOLD}claude-sandbox${RESET} to pick a repo and go."
echo -e "  Run ${BOLD}claude-sandbox help${RESET} for all commands."
echo ""

if [[ -z "${ANTHROPIC_API_KEY:-}" ]]; then
    echo -e "  ${DIM}Don't forget to set your API key:${RESET}"
    echo -e "  ${BOLD}export ANTHROPIC_API_KEY=sk-ant-...${RESET}"
    echo ""
fi
