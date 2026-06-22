# Live Adapter Quick Start

Frank Workflow ships dry-run bridge adapters so CI and examples work without AI CLIs or private plugins. For live multi-agent work, install tools in your own environment and connect them through environment variables.

## 1. Install external tools

Minimum live setup:

| Tool | Purpose |
|---|---|
| Claude Code CLI or compatible command | Reviewer role. |
| Codex CLI or compatible command | Developer role. |
| `tmux` | Interactive session host for terminal-based adapters. |
| `tmux-bridge` or compatible pane helper | Optional pane addressing layer. |

Optional:

| Tool | Purpose |
|---|---|
| Gemini CLI or compatible scout | Scout role. |
| `gitleaks` | Local secret scan before publishing. |
| `shellcheck` | Shell linting. |

Install these outside this repository. Do not copy CLI caches, plugin caches, browser profiles, auth stores, or private overlays into Git.

## 2. Check environment

```bash
./scripts/check-env.sh --live
```

Missing optional tools are reported as warnings. Required framework tools are `bash`, `git`, and `python3`.

## 3. Point adapters at live commands

Use environment variables when your live adapter is not on `PATH`:

```bash
export CLAUDE_BRIDGE_BIN="$HOME/.local/bin/claude-official-bridge"
export CODEX_BRIDGE_BIN="$HOME/.local/bin/codex-bridge"
export GEMINI_BRIDGE_BIN="$HOME/.local/bin/gemini-bridge"
export TMUX_BRIDGE_BIN="$HOME/.local/bin/tmux-bridge"
```

The public dry-run adapters remain useful for tests:

```bash
CLAUDE_BRIDGE_DRY_RUN=1 bridges/claude/claude-official-bridge send templates/review-request.md
CODEX_BRIDGE_DRY_RUN=1 bridges/codex/codex-bridge status
GEMINI_BRIDGE_DRY_RUN=1 bridges/gemini/gemini-bridge status
```

## 4. Keep private overlays external

Private team rules belong outside this repository, for example:

```bash
export FRANK_WORKFLOW_OVERLAY_DIR="$HOME/.frank-workflow/overlays/default"
```

Local overlays should contain only your own private policy, persona, memory settings, and runtime paths. Never commit those files to the public core.

## 5. Pre-publish safety checks

Before publishing a derived workflow or example, run:

```bash
./tests/run.sh
./scripts/secret-scan.sh
gitleaks dir --no-banner --redact .
```

If your organization has private project names or infrastructure markers, keep them in an uncommitted denylist and pass it to the scanner:

```bash
EXTRA_SECRET_SCAN_DENYLIST="$HOME/.frank-workflow/private-denylist.txt" ./scripts/secret-scan.sh
```
