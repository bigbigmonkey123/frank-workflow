#!/usr/bin/env bash
set -euo pipefail
bash -n bridges/claude/claude-official-bridge bridges/claude/claude-entrypoint-probe.sh bridges/codex/codex-bridge bridges/gemini/gemini-bridge scripts/*.sh tests/*.sh
./scripts/check-env.sh
./tests/bridge-marker-test.sh
./tests/secret-scan-test.sh
./tests/docs-lint-test.sh
CLAUDE_BRIDGE_DRY_RUN=1 bridges/claude/claude-official-bridge send templates/review-request.md | grep -q 'dryrun-0001'
CODEX_BRIDGE_DRY_RUN=1 bridges/codex/codex-bridge status | grep -q 'dry-run ok'
GEMINI_BRIDGE_DRY_RUN=1 bridges/gemini/gemini-bridge status | grep -q 'dry-run ok'
echo "all tests passed"
