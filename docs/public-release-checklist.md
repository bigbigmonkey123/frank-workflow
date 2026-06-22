# Public Release Checklist

- [ ] Fresh Git repository, no private history.
- [ ] `./tests/run.sh` passes.
- [ ] `./scripts/secret-scan.sh` passes.
- [ ] `gitleaks dir --no-banner --redact .` passes when gitleaks is installed.
- [ ] README, LICENSE, NOTICE, SECURITY, CONTRIBUTING, CHANGELOG exist.
- [ ] Claude pre-publication review completed.
- [ ] Runtime tools/plugins documented as external environment requirements; no plugin caches, credentials, or private helpers are vendored.
