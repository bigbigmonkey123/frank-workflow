# Codex Bootstrap Guide

This guide is for a user who wants Codex to set up Frank Workflow quickly in a new repository.

## Fast path

From the cloned `frank-workflow` repository:

```bash
./scripts/bootstrap.sh --project /path/to/your-project --name your-project
```

This command:

1. Checks required tools (`bash`, `git`, `python3`).
2. Installs framework templates under `$FRANK_WORKFLOW_HOME` or `$HOME/.frank-workflow`.
3. Creates project-local `.frank-workflow/config.toml` and `.frank-workflow/project.md`.
4. Generates `AGENTS.md` with the neutral persona template when absent.
5. Copies `CLAUDE.md`, review request, post-dev review, and QA templates.
6. Runs dry-run Claude/Codex/Gemini adapter smoke tests.

## Codex prompt to initialize a project

Paste this into Codex from inside your target project:

```text
Use Frank Workflow from /path/to/frank-workflow. Run:
/path/to/frank-workflow/scripts/bootstrap.sh --project "$PWD" --name "$(basename "$PWD")"
Then inspect AGENTS.md, CLAUDE.md, and .frank-workflow/project.md. Do not add secrets or private credentials. Run /path/to/frank-workflow/tests/run.sh if changing the framework itself.
```

## Live tools

Dry-run adapters work immediately. For real Claude/Codex/Gemini runs, install the external CLIs yourself and verify:

```bash
./scripts/check-env.sh --live
```

If commands are not on `PATH`, configure environment variables:

```bash
export CLAUDE_BRIDGE_BIN="$HOME/.local/bin/claude-official-bridge"
export CODEX_BRIDGE_BIN="$HOME/.local/bin/codex-bridge"
export GEMINI_BRIDGE_BIN="$HOME/.local/bin/gemini-bridge"
```

## Safety

Before sharing or publishing a derived project, run:

```bash
./scripts/secret-scan.sh
gitleaks dir --no-banner --redact .
```

Keep project secrets, browser profiles, API keys, OAuth tokens, plugin caches, and private overlays outside Git.
