# Public Release Checklist

- [ ] Fresh Git repository, no private history.
- [ ] `./tests/run.sh` passes.
- [ ] `./scripts/secret-scan.sh` passes.
- [ ] `gitleaks dir --no-banner --redact .` passes when gitleaks is installed.
- [ ] README, LICENSE, NOTICE, SECURITY, CONTRIBUTING, CHANGELOG exist.
- [ ] Claude pre-publication review completed.
- [ ] Runtime tools/plugins/MCP services documented as external environment requirements; no plugin caches, MCP server configs, credentials, or private helpers are vendored.

## v0.1.0 Evidence

- [x] Fresh Git repository, no private history: single root commit `d011ce5` before release prep.
- [x] `./tests/run.sh` passed locally and in GitHub Actions run `27934800704`.
- [x] `./scripts/secret-scan.sh` passed.
- [x] `gitleaks dir --no-banner --redact .` passed.
- [x] README, LICENSE, NOTICE, SECURITY, CONTRIBUTING, CHANGELOG exist.
- [x] Claude pre-publication review completed: `20260622T064535Z-62986-9971fa23`, verdict `APPROVED`.
- [x] Runtime tools/plugins/MCP services documented as external environment requirements in `docs/runtime-environment.md`.
