# Frank Workflow

[![ci](https://github.com/bigbigmonkey123/frank-workflow/actions/workflows/ci.yml/badge.svg)](https://github.com/bigbigmonkey123/frank-workflow/actions/workflows/ci.yml)
[![release](https://img.shields.io/badge/release-v0.1.1-blue)](https://github.com/bigbigmonkey123/frank-workflow/releases/tag/v0.1.1)

Frank Workflow is a bridge-protocol-driven, multi-agent development workflow. It provides a Codex-oriented developer adapter, a Claude review adapter, and an optional Gemini/smux scout adapter, while keeping team- or user-specific behavior in overlays.

## Why

- Keep implementation and review separate.
- Make review gates reproducible through archived artifacts.
- Let teams customize persona, memory, risk gates, and local tooling without forking the core workflow.

## Quick Start

```bash
git clone https://github.com/bigbigmonkey123/frank-workflow
cd frank-workflow
./scripts/bootstrap.sh --project /tmp/frank-workflow-demo --name demo --dry-run
./scripts/bootstrap.sh --project /tmp/frank-workflow-demo --name demo
```

Expected dry-run output includes a deterministic task id and a sample verdict.

## Roles

| Role | Default Adapter | Purpose |
|---|---|---|
| Developer | Codex adapter | Implement, patch, and run local QA. |
| Reviewer | Claude adapter | Pre-dev and post-dev review gates. |
| Scout | Gemini adapter | Broad context, UI scouting, or alternate reasoning. |
| Human | Manual FTW gate | Production, destructive, expensive, or irreversible decisions. |

Codex is an adapter, not a hard dependency. Any CLI can implement the bridge protocol for the Developer role.

## Repository Layout

- `bridges/` — adapter scripts for Claude, Codex, Gemini, and tmux dependency docs.
- `docs/` — workflow, bridge protocol, customization, and release docs.
- `templates/` — AGENTS/CLAUDE/review/QA templates and persona examples.
- `examples/minimal-project/` — no-runtime demo project.
- `scripts/` — install, env check, render, secret scan, docs lint.
- `tests/` — dry-run and static tests.

## Runtime Tools

This repo does not vendor Claude/Codex/Gemini CLIs, Codex plugins, MCP services, smux/tmux helpers, credentials, browser profiles, or private overlays. Install those in the user environment and verify them with `./scripts/check-env.sh --live`. The default tests use dry-run adapters and require only `bash`, `git`, and `python3`. See `docs/runtime-environment.md`.

## Codex Bootstrap

To let Codex initialize a target project quickly, point it at this repository and ask it to run `scripts/bootstrap.sh --project "$PWD" --name "$(basename "$PWD")"`. See `docs/codex-bootstrap.md`.

## Live Adapter Setup

The default quick start uses dry-run adapters. For real Claude/Codex/Gemini execution, install those CLIs in your own environment and point Frank Workflow at them with environment variables. See `docs/quickstart-live-adapters.md`.

## Private Overlays

Public core runs without overlays. Users may attach private overlays through `.frank-workflow/config.toml`, `FRANK_WORKFLOW_OVERLAY_DIR`, or CLI flags. Private overlays should stay outside public Git history.
