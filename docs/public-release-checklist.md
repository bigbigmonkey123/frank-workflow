# Public Release Checklist

- [ ] Fresh Git repository, no private history.
- [ ] `./tests/run.sh` passes.
- [ ] `./scripts/secret-scan.sh` passes.
- [ ] `gitleaks dir --no-banner --redact .` passes when gitleaks is installed.
- [ ] README, LICENSE, NOTICE, SECURITY, CONTRIBUTING, CHANGELOG exist.
- [ ] Claude pre-publication review completed.
- [ ] Runtime tools/plugins/MCP services documented as external environment requirements; no plugin caches, MCP server configs, credentials, or private helpers are vendored.
- [ ] `VERSION`, README release badge, CHANGELOG heading, Git tag, and release title agree.
- [ ] Runtime artifact roots are gitignored and no task artifacts are staged.

## v0.1.0 Evidence

- [x] Fresh Git repository, no private history: single root commit `d011ce5` before release prep.
- [x] `./tests/run.sh` passed locally and in GitHub Actions run `27934800704`.
- [x] `./scripts/secret-scan.sh` passed.
- [x] `gitleaks dir --no-banner --redact .` passed.
- [x] README, LICENSE, NOTICE, SECURITY, CONTRIBUTING, CHANGELOG exist.
- [x] Claude pre-publication review completed: `20260622T064535Z-62986-9971fa23`, verdict `APPROVED`.
- [x] Runtime tools/plugins/MCP services documented as external environment requirements in `docs/runtime-environment.md`.

## v0.2.0 Evidence Template

- [ ] `./tests/run.sh` and `./scripts/secret-scan.sh` pass.
- [ ] Bridge lifecycle tests cover unique ids, collisions, concurrency, timeout, cleanup, and read-only status.
- [ ] Capacity tests cover safe fallback, exit `74`, exit `75`, non-capacity passthrough, and capacity-looking success output.
- [ ] Independent post-development review approves the exact release diff.
- [ ] `VERSION == README badge == CHANGELOG == v0.2.0`.
