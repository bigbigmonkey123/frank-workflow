# Migrating from v0.1.x to v0.2.0

## Behavior Changes

- Reviewer dry-run task ids are unique. Parse `task_id=` from `send`; do not assume `dryrun-0001`.
- Dry-run reviewer tasks create gitignored artifacts and support `wait`, `read`, `status`, and `cleanup`.
- Review approvals are invalid after any later tracked change in reviewed scope.
- Ordinary `REVISE` and QA failures auto-flow; the hard-stop matrix is narrower and explicit.

## Existing Projects

Back up and diff `AGENTS.md`, `CLAUDE.md`, and `.frank-workflow/config.toml` before running bootstrap with `--force`. Force mode overwrites generated files and does not merge custom content.

Without `--force`, v0.2 bootstrap preserves existing generated files and configuration.

```bash
cp AGENTS.md AGENTS.md.v0.1-backup
cp CLAUDE.md CLAUDE.md.v0.1-backup
./scripts/bootstrap.sh --project /path/to/project --name project-name
```

To keep deterministic dry-run fixtures temporarily:

```bash
FRANK_BRIDGE_DRY_RUN_TASK_ID=dryrun-0001 \
  CLAUDE_BRIDGE_DRY_RUN=1 bridges/claude/claude-official-bridge send review.md
```

Reusing that id in the same artifact root fails closed rather than overwriting evidence.

## Rollback

Pin tag `v0.1.2` and reinstall its copy-based templates. There is no database or service migration.
