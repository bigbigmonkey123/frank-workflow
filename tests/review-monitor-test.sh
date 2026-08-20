#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
export CLAUDE_BRIDGE_DRY_RUN=1
source "$ROOT/bridges/lib/artifact-helpers.sh"

tmp="$(mktemp -d "${TMPDIR:-/tmp}/frank-monitor-test.XXXXXX")"
trap 'rm -rf "$tmp"' EXIT

ARTIFACT_ROOT="$tmp/artifacts"
frank_ensure_artifact_root "$ARTIFACT_ROOT"

# --- Test 1: Normal completion (heartbeat + response present) ---
task_id="monitor-test-ok"
task_dir="$ARTIFACT_ROOT/$task_id"
mkdir "$task_dir"
created_at="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
printf 'TASK_ID=%s\nROLE=reviewer\nMODE=dry-run\nCREATED_AT=%s\n' "$task_id" "$created_at" | frank_atomic_write "$task_dir/session.env"
echo "test prompt" | frank_atomic_write "$task_dir/request.md"
frank_write_heartbeat "$task_dir"
cat <<'OUT' | frank_atomic_write "$task_dir/response.md"
VERDICT: APPROVED
FINDINGS:
- test ok
RECOMMENDATIONS:
EVIDENCE:
OUT
output="$("$ROOT/bridges/lib/review-monitor" "$ARTIFACT_ROOT" "$task_id" --receipt-timeout 5 --check-interval 1 --stale-threshold 10 2>&1)"
echo "$output" | grep -q "review completed" || { echo "FAIL: test 1 — expected completion"; exit 1; }
echo "PASS: test 1 — normal completion"

# --- Test 2: Receipt timeout (no heartbeat) ---
task_id="monitor-test-no-hb"
task_dir="$ARTIFACT_ROOT/$task_id"
mkdir "$task_dir"
created_at="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
printf 'TASK_ID=%s\nROLE=reviewer\nMODE=dry-run\nCREATED_AT=%s\n' "$task_id" "$created_at" | frank_atomic_write "$task_dir/session.env"
echo "test prompt" | frank_atomic_write "$task_dir/request.md"
set +e
"$ROOT/bridges/lib/review-monitor" "$ARTIFACT_ROOT" "$task_id" --receipt-timeout 2 --check-interval 1 --stale-threshold 5 >/dev/null 2>&1
rc=$?
set -e
[[ "$rc" -eq 2 ]] || { echo "FAIL: test 2 — expected exit 2, got $rc"; exit 1; }
echo "PASS: test 2 — receipt timeout (exit 2)"

# --- Test 3: Stale detection (old heartbeat, no response) ---
task_id="monitor-test-stale"
task_dir="$ARTIFACT_ROOT/$task_id"
mkdir "$task_dir"
created_at="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
printf 'TASK_ID=%s\nROLE=reviewer\nMODE=dry-run\nCREATED_AT=%s\n' "$task_id" "$created_at" | frank_atomic_write "$task_dir/session.env"
echo "test prompt" | frank_atomic_write "$task_dir/request.md"
# Write an old heartbeat (10 minutes ago)
echo "2020-01-01T00:00:00Z" | frank_atomic_write "$task_dir/heartbeat"
set +e
"$ROOT/bridges/lib/review-monitor" "$ARTIFACT_ROOT" "$task_id" --receipt-timeout 5 --check-interval 1 --stale-threshold 3 >/dev/null 2>&1
rc=$?
set -e
[[ "$rc" -eq 3 ]] || { echo "FAIL: test 3 — expected exit 3, got $rc"; exit 1; }
echo "PASS: test 3 — stale detection (exit 3)"

# --- Test 3b: Stale detection with recent heartbeat (timezone regression guard) ---
task_id="monitor-test-stale-recent"
task_dir="$ARTIFACT_ROOT/$task_id"
mkdir "$task_dir"
created_at="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
printf 'TASK_ID=%s\nROLE=reviewer\nMODE=dry-run\nCREATED_AT=%s\n' "$task_id" "$created_at" | frank_atomic_write "$task_dir/session.env"
echo "test prompt" | frank_atomic_write "$task_dir/request.md"
# Write a heartbeat from 10 seconds ago (just over a 3s threshold)
hb_time="$(date -u -v-10S +%Y-%m-%dT%H:%M:%SZ 2>/dev/null || date -u -d '10 seconds ago' +%Y-%m-%dT%H:%M:%SZ)"
echo "$hb_time" | frank_atomic_write "$task_dir/heartbeat"
set +e
"$ROOT/bridges/lib/review-monitor" "$ARTIFACT_ROOT" "$task_id" --receipt-timeout 5 --check-interval 1 --stale-threshold 3 >/dev/null 2>&1
rc=$?
set -e
[[ "$rc" -eq 3 ]] || { echo "FAIL: test 3b — expected exit 3 for 10s-old heartbeat with 3s threshold, got $rc"; exit 1; }
echo "PASS: test 3b — stale detection with recent heartbeat (timezone guard)"

# --- Test 4: bridge health command ---
task_id="monitor-test-health"
task_dir="$ARTIFACT_ROOT/$task_id"
mkdir "$task_dir"
created_at="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
printf 'TASK_ID=%s\nROLE=reviewer\nMODE=dry-run\nCREATED_AT=%s\n' "$task_id" "$created_at" | frank_atomic_write "$task_dir/session.env"

# 4a: no heartbeat → dead
output="$(FRANK_BRIDGE_ARTIFACT_ROOT="$ARTIFACT_ROOT" "$ROOT/bridges/claude/claude-official-bridge" health "$task_id")"
echo "$output" | grep -q "dead" || { echo "FAIL: test 4a — expected dead"; exit 1; }
echo "PASS: test 4a — health dead"

# 4b: fresh heartbeat → alive
frank_write_heartbeat "$task_dir"
output="$(FRANK_BRIDGE_ARTIFACT_ROOT="$ARTIFACT_ROOT" "$ROOT/bridges/claude/claude-official-bridge" health "$task_id")"
echo "$output" | grep -q "alive" || { echo "FAIL: test 4b — expected alive"; exit 1; }
echo "PASS: test 4b — health alive"

# 4c: with response → done
cat <<'OUT' | frank_atomic_write "$task_dir/response.md"
VERDICT: APPROVED
FINDINGS:
RECOMMENDATIONS:
EVIDENCE:
OUT
output="$(FRANK_BRIDGE_ARTIFACT_ROOT="$ARTIFACT_ROOT" "$ROOT/bridges/claude/claude-official-bridge" health "$task_id")"
echo "$output" | grep -q "done" || { echo "FAIL: test 4c — expected done"; exit 1; }
echo "PASS: test 4c — health done"

# --- Test 5: send now writes heartbeat ---
task_id="monitor-test-send-hb"
output="$(FRANK_BRIDGE_ARTIFACT_ROOT="$ARTIFACT_ROOT" FRANK_BRIDGE_DRY_RUN_TASK_ID="$task_id" "$ROOT/bridges/claude/claude-official-bridge" send "test")"
[[ -f "$ARTIFACT_ROOT/$task_id/heartbeat" ]] || { echo "FAIL: test 5 — send did not write heartbeat"; exit 1; }
echo "PASS: test 5 — send writes heartbeat"

echo "all review-monitor tests passed"
