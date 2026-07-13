# Changelog

## [v0.2.0] - 2026-07-12

### Added
- Unique reviewer dry-run task ids with request, response, session, and metadata artifacts.
- Dry-run wait, read, status, cleanup, start, and stop lifecycle behavior.
- Vendor-neutral fail-closed capacity guard with exit `74`/`75` semantics and replay-safety tests.
- Continuous-execution, hard-stop, review-invalidation, and v0.1 migration documentation.
- `VERSION` as the release-version source.

### Changed
- Reviewer dry-run consumers must parse `task_id=` instead of assuming `dryrun-0001`.
- Bootstrap now verifies reviewer send/wait and preserves existing generated config unless `--force` is supplied.
- Explicit live adapter environment overrides delegate to external binaries.

### Fixed
- README release badge drift.

### Security
- Unknown replay safety always fails closed with exit `74`; partial or unknown execution is never blindly replayed.
- Artifact roots are gitignored and task directories use user-only permissions where supported.

## [v0.1.2] - 2026-06-22

### Changed
- Clarified that MCP services are external environment requirements and must not be vendored into the public repository.

## [v0.1.1] - 2026-06-22

### Added
- One-command bootstrap script for installing templates, initializing target projects, generating AGENTS/CLAUDE files, and running dry-run adapter smoke tests.
- Codex bootstrap guide for fast setup in downstream projects.
- Live adapter quick-start documentation for external Claude/Codex/Gemini tool setup.

### Changed
- CODEOWNERS now points at the repository owner instead of placeholder team handles.

## [v0.1.0] - 2026-06-22

### Added
- Public Frank Workflow core with docs, templates, examples, CI, and release checklist.
- Dry-run bridge adapters for Claude, Codex, and Gemini roles.
- Bridge protocol, review-gate, workflow, customization, and memory-model documentation.
- Runtime-environment boundary: live CLIs, plugins, skills, tmux/smux helpers, credentials, browser profiles, and private overlays are external user environment requirements, not repository content.
- Secret scanning, docs lint, dry-run adapter tests, and GitHub Actions CI.

### Security
- Public repository initialized from a fresh single-commit history.
- Release checks include `secret-scan.sh`, `gitleaks`, extended private-marker scans, and Claude bridge review.
