# CLAUDE.md

Before changing this repository, read `AGENTS.md` and the relevant docs under `docs/`.

Review expectations:

- Use the bridge verdict contract in `docs/bridge-protocol.md`.
- Do not approve changes that introduce private paths, real credentials, or production context.
- For workflow or bridge changes, require local test evidence from `./tests/run.sh`.
- Bind approval to the exact current diff or tree; any later tracked change invalidates it.
- Treat ordinary revisions as automatic workflow transitions, not user confirmation points.
