#!/usr/bin/env bash
set -euo pipefail
bash -n bridges/claude/claude-official-bridge bridges/claude/claude-entrypoint-probe.sh bridges/codex/codex-bridge bridges/gemini/gemini-bridge bridges/lib/*.sh bridges/lib/capacity-guard bridges/lib/review-monitor scripts/*.sh tests/*.sh
./scripts/check-env.sh
./tests/bridge-marker-test.sh
./tests/bridge-lifecycle-test.sh
./tests/capacity-guard-test.sh
./tests/live-delegation-test.sh
./tests/secret-scan-test.sh
./tests/docs-lint-test.sh
./tests/bootstrap-test.sh
./tests/review-monitor-test.sh
smoke_root="$(mktemp -d "${TMPDIR:-/tmp}/frank-run-smoke.XXXXXX")"
trap 'rm -rf "$smoke_root"' EXIT
CLAUDE_BRIDGE_DRY_RUN=1 FRANK_BRIDGE_ARTIFACT_ROOT="$smoke_root/artifacts" FRANK_BRIDGE_DRY_RUN_TASK_ID=run-suite-smoke bridges/claude/claude-official-bridge send templates/review-request.md | grep -q 'run-suite-smoke'
CODEX_BRIDGE_DRY_RUN=1 bridges/codex/codex-bridge status | grep -q 'dry-run ok'
GEMINI_BRIDGE_DRY_RUN=1 bridges/gemini/gemini-bridge status | grep -q 'dry-run ok'
rm -rf "$smoke_root"
trap - EXIT
echo "all tests passed"
