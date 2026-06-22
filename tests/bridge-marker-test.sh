#!/usr/bin/env bash
set -euo pipefail
out=$(CLAUDE_BRIDGE_DRY_RUN=1 bridges/claude/claude-official-bridge wait dryrun-0001 5)
printf '%s
' "$out" | grep -q 'VERDICT: APPROVED_WITH_RISKS'
