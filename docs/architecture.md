# Architecture

Frank Workflow is split into:

- public core: protocol, bridges, templates, tests, docs;
- private overlay: persona, memory, provider config, project context.

The public repository must be created with fresh Git history and populated only from allowlisted sanitized files.

## v0.2 Runtime Shape

- The Claude reviewer dry-run is the executable reference for unique task ids and archived artifacts.
- Live adapters stay external and are selected through environment overrides.
- Codex and Gemini retain thin dry-run status adapters; full lifecycle parity is planned for v0.2.1.
- `bridges/lib/artifact-helpers.sh` provides portable task ids and atomic metadata writes.
- `bridges/lib/capacity-guard` provides optional vendor-neutral, fail-closed retry protection.

Runtime artifacts stay outside tracked source under adapter-specific ignored roots. They can contain prompt content and must be cleaned according to the operator's retention policy.
