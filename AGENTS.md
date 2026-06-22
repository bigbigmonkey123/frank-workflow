# Frank Workflow

Reusable bridge-protocol-driven workflow core for multi-agent software development.

## Golden Rules

- Public core must remain free of private paths, real production domains, real IP addresses, credentials, and customer context.
- Codex, Claude, and Gemini are adapters; the stable contract is the bridge protocol.
- Use evidence-first development: inspect, decide, implement, verify, review, report.
- Keep overlays explicit and local; do not import private overlays by default.

## Where To Look

| Task | Read First |
|---|---|
| Workflow gates | `docs/workflow.md` |
| Bridge protocol | `docs/bridge-protocol.md` |
| Runtime environment | `docs/runtime-environment.md` |
| Live adapter setup | `docs/quickstart-live-adapters.md` |
| Codex bootstrap | `docs/codex-bootstrap.md` |
| Custom overlays | `docs/customization.md` |
| Memory model | `docs/memory-model.md` |
| Release safety | `docs/public-release-checklist.md` |
| Commands | `docs/commands.md` |

## Commands

| Action | Command |
|---|---|
| Check env | `./scripts/check-env.sh` |
| Run tests | `./tests/run.sh` |
| Secret scan | `./scripts/secret-scan.sh` |
| Docs lint | `./scripts/docs-lint.sh` |

## Update Triggers

Update docs and tests when bridge protocol, overlay lifecycle, release checks, templates, or adapter behavior changes.
