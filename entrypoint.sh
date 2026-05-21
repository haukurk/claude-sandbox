#!/usr/bin/env bash
set -euo pipefail

# Copy read-only host config into a writable location so Claude can
# persist workspace trust, session state, etc. inside the container.
if [[ -d /home/claude/.claude-host ]]; then
    cp -a /home/claude/.claude-host/. /home/claude/.claude/ 2>/dev/null || true
fi

if [[ -f /home/claude/.claude-host.json ]]; then
    cp /home/claude/.claude-host.json /home/claude/.claude.json 2>/dev/null || true
fi

if [[ -f /home/claude/.mcp-host.json ]]; then
    cp /home/claude/.mcp-host.json /home/claude/.mcp.json 2>/dev/null || true
fi

# Ensure credentials extracted from macOS Keychain are in place
if [[ -f /home/claude/.claude/.credentials.json ]]; then
    chmod 600 /home/claude/.claude/.credentials.json 2>/dev/null || true
fi

# Always set status line to the bundled container path — host paths don't exist here.
if [[ -f /home/claude/.claude/settings.json ]]; then
    tmp=$(mktemp)
    python3 -c "
import json
with open('/home/claude/.claude/settings.json') as f:
    cfg = json.load(f)
cfg['statusLine'] = {'type': 'command', 'command': 'bash /usr/local/bin/statusline.sh'}
with open('$tmp', 'w') as f:
    json.dump(cfg, f, indent=4)
" 2>/dev/null && mv "$tmp" /home/claude/.claude/settings.json
else
    mkdir -p /home/claude/.claude
    echo '{"statusLine":{"type":"command","command":"bash /usr/local/bin/statusline.sh"}}' > /home/claude/.claude/settings.json
fi

exec claude --dangerously-skip-permissions "$@"
