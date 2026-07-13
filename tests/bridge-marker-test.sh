#!/usr/bin/env bash
set -euo pipefail
root="$(mktemp -d "${TMPDIR:-/tmp}/frank-marker-test.XXXXXX")"
trap 'rm -rf "$root"' EXIT
send_out=$(CLAUDE_BRIDGE_DRY_RUN=1 FRANK_BRIDGE_ARTIFACT_ROOT="$root" bridges/claude/claude-official-bridge send templates/review-request.md)
task_id=$(printf '%s\n' "$send_out" | sed -n 's/^Task sent: task_id=//p')
out=$(CLAUDE_BRIDGE_DRY_RUN=1 FRANK_BRIDGE_ARTIFACT_ROOT="$root" bridges/claude/claude-official-bridge wait "$task_id" 5)
printf '%s\n' "$out" | grep -q 'VERDICT: APPROVED_WITH_RISKS'
