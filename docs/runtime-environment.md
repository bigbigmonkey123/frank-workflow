# Runtime Environment

Frank Workflow is a framework and protocol package. It must not vendor or embed local AI plugins, private skills, CLI sessions, credentials, browser profiles, or workstation-specific helper binaries.

## Boundary

| Category | In this repo | Installed in user environment |
|---|---|---|
| Workflow docs and templates | Yes | No |
| Bridge protocol and dry-run adapters | Yes | No |
| Live Claude/Codex/Gemini CLIs | No | Yes |
| Codex/Claude plugins and skills | No | Yes |
| MCP server implementations and configs | No | Yes |
| tmux/smux helpers | No | Yes |
| API keys, OAuth, browser profiles, memories | Never | User-controlled only |

The public repository provides only protocol-compatible adapter stubs and dry-run tests. Live adapters are resolved from the environment at runtime.

## Required Tools

Minimum required for repository tests and template rendering:

| Tool | Purpose |
|---|---|
| `bash` | Run install, tests, and bridge adapter scripts. |
| `git` | Clone and version projects using the workflow. |
| `python3` | Render templates and run lightweight checks. |

## Optional Live Adapters and Tooling

Install these outside the repo when you want live multi-agent operation or stronger local QA:

| Tool | Role | Env override |
|---|---|---|
| Claude Code CLI | Reviewer adapter | `CLAUDE_BRIDGE_BIN` |
| Codex CLI | Developer adapter | `CODEX_BRIDGE_BIN` |
| Gemini CLI or compatible scout | Scout adapter | `GEMINI_BRIDGE_BIN` |
| `tmux` | Interactive bridge session host | `TMUX_BIN` |
| `tmux-bridge` / smux-compatible helper | Pane addressing | `TMUX_BRIDGE_BIN` |
| `gitleaks` | Secret scanning | none |
| `shellcheck` | Shell linting | none |

## Install Model

`./scripts/install.sh` installs framework templates and example config into `$FRANK_WORKFLOW_HOME` only. It does not install AI CLIs, plugins, skills, MCP servers, credentials, or private overlays.

Use `./scripts/check-env.sh --live` to verify optional live adapters are present. Without `--live`, the command checks only the minimum framework requirements.

## Adapter Resolution

Live wrappers should resolve adapter binaries in this order:

1. Explicit environment variable such as `CLAUDE_BRIDGE_BIN`.
2. `PATH` lookup.
3. A user config value under `$FRANK_WORKFLOW_HOME/config.toml`.
4. Fail with install instructions.

Do not commit machine-specific absolute paths. Examples should use placeholders:

```bash
export CLAUDE_BRIDGE_BIN="$HOME/.local/bin/claude-official-bridge"
export CODEX_BRIDGE_BIN="$HOME/.local/bin/codex-bridge"
export GEMINI_BRIDGE_BIN="$HOME/.local/bin/gemini-bridge"
```

## Plugin and MCP Policy

Plugins and MCP services are environment requirements, not repository content:

- Keep plugin installation in the user's Codex/Claude/Gemini environment.
- Keep MCP server installation and MCP configuration in the user's AI CLI environment or private overlay.
- Document plugin or MCP server names and minimum versions when a workflow needs them.
- Do not copy plugin source, plugin cache, MCP server source, MCP config files, browser profiles, auth stores, or generated runtime state into this repo.
- CI must pass without live plugins or MCP services by using dry-run adapters.
