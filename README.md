# claude-sandbox

Run Claude Code off-leash — inside a container, so your filesystem stays out of reach.

`--dangerously-skip-permissions` lets Claude *frussukóða* your code — no prompts, no guardrails, pure autonomy. The problem is it can frussukóða your entire machine just as easily. SSH keys, `.env` files, other repos, that folder of unsorted screenshots from 2019 — all fair game.

This puts Claude in a fenced yard. Pick a repo, it gets mounted into a Docker container, and that's all Claude can see. It can `rm -rf /` all day and the only casualty is a disposable container.

## Install

One command:

```bash
curl -fsSL https://raw.githubusercontent.com/haukurk/claude-sandbox/main/install.sh | bash
```

This clones the repo, builds the Docker image, and links `claude-sandbox` to your PATH.

Or do it manually:

```bash
git clone https://github.com/haukurk/claude-sandbox.git ~/.claude-sandbox
cd ~/.claude-sandbox
./install.sh
```

## Quick start

```bash
export ANTHROPIC_API_KEY=sk-ant-...

# Interactive — pick a repo from a list
claude-sandbox

# Direct — point it at a repo
claude-sandbox run ~/my-project
```

Just run `claude-sandbox` with no arguments. It finds your git repos, you pick one, and Claude goes to work — with only that repo mounted. Nothing else is accessible.

If you have [fzf](https://github.com/junegunn/fzf) installed, you get a fuzzy search picker. Otherwise, a numbered menu.

## Commands

```
claude-sandbox                                       Pick a repo and go (interactive)
claude-sandbox run <path> [opts] [-- claude args]    Launch Claude on a specific repo
claude-sandbox build [--no-cache] [version]           Build/rebuild the Docker image
claude-sandbox list                                   See what's running
claude-sandbox stop <name|all>                        Pull the plug
claude-sandbox shell <path>                           Poke around the container yourself
claude-sandbox help                                   You're reading it
```

## Examples

```bash
# Interactive picker (the default)
claude-sandbox

# Give Claude a mission
claude-sandbox run ~/repos/my-app -- -p "fix the bug in auth.ts"

# Big project, big resources
claude-sandbox run -m 8g -c 4 ~/repos/monorepo

# Trust nobody (full network isolation)
claude-sandbox run --network none ~/repos/sketchy-fork

# Something broke, let me look around
claude-sandbox shell ~/repos/my-app

# Update Claude Code in the image
claude-sandbox build --no-cache

# Done for the day
claude-sandbox stop all
```

## Options for `run`

| Flag | Default | Description |
|------|---------|-------------|
| `-m, --memory` | `4g` | Container memory limit |
| `-c, --cpus` | `2` | CPU limit |
| `-n, --network` | `host` | `host`, `none`, or `bridge` |
| `-i, --image` | `claude-sandbox:latest` | Custom image |
| `--no-config` | | Don't mount `~/.claude` |
| `--build` | | Rebuild image first |
| `--name` | | Custom container name |

## What Claude can and can't touch

| | Access |
|---|---|
| Your repo | Read-write (that's the point) |
| `~/.claude` config | Read-only (auth carries over) |
| Your home directory | Nope |
| Your filesystem | Nope |
| Other repos | Nope |
| Network | Up to you (`host` / `none` / `bridge`) |
| RAM / CPU | Capped |

## Repo discovery

By default, `claude-sandbox` scans these directories for git repos (up to 3 levels deep):

```
~/Repos  ~/repos  ~/projects  ~/src  ~/code  ~/dev  ~/work
```

Customize with:

```bash
export CLAUDE_SANDBOX_REPO_DIRS="$HOME/my-stuff:$HOME/work/clients"
```

## Authentication

```bash
# Option 1: env var (recommended)
export ANTHROPIC_API_KEY=sk-ant-...

# Option 2: .env file
cp .env.example .env  # fill in your key
source .env
```

AWS Bedrock and Google Vertex are also supported — see `.env.example`.

If you've already run `claude` on your host, the `~/.claude` config is mounted read-only so your session just works.

## What's in the box

Debian slim, Node 22, git, ripgrep, fd, curl, jq, python3, build-essential, and Claude Code. Runs as a non-root user. Nothing fancy, nothing extra.

## Updating

```bash
# Re-run the installer (pulls latest + rebuilds image)
curl -fsSL https://raw.githubusercontent.com/haukurk/claude-sandbox/main/install.sh | bash

# Or just rebuild the Docker image
claude-sandbox build --no-cache
```

## Requirements

- Docker
- An API key

## License

MIT
