# Changelog

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
