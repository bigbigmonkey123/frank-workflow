#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BRIDGE="$ROOT/bridges/claude/claude-official-bridge"
TMPROOT="$(mktemp -d "${TMPDIR:-/tmp}/frank-bridge-lifecycle.XXXXXX")"
cleanup() { rm -rf "$TMPROOT"; }
trap cleanup EXIT
ARTIFACT_ROOT="$TMPROOT/artifacts"

for ignored in .claude-bridge/probe .codex-shared/probe .codex-agent-shared/probe .gemini-shared/probe .frank-capacity-guard/probe; do
  git -C "$ROOT" check-ignore -q "$ignored" || { echo "runtime root is not ignored: $ignored" >&2; exit 1; }
done

send_task() {
  local output
  output="$(CLAUDE_BRIDGE_DRY_RUN=1 FRANK_BRIDGE_ARTIFACT_ROOT="$ARTIFACT_ROOT" "$BRIDGE" send "$1")"
  printf '%s\n' "$output" | sed -n 's/^Task sent: task_id=//p'
}

task_a="$(send_task 'review alpha')"
task_b="$(send_task 'review beta')"
[[ -n "$task_a" && -n "$task_b" && "$task_a" != "$task_b" ]]
for task_id in "$task_a" "$task_b"; do
  printf '%s\n' "$task_id" | grep -Eq '^[0-9]{8}T[0-9]{6}Z-[0-9]+-[0-9a-f]{8}$'
  for file in request.md session.env response.md metadata.json; do
    [[ -f "$ARTIFACT_ROOT/$task_id/$file" ]] || { echo "missing artifact: $task_id/$file" >&2; exit 1; }
  done
  CLAUDE_BRIDGE_DRY_RUN=1 FRANK_BRIDGE_ARTIFACT_ROOT="$ARTIFACT_ROOT" "$BRIDGE" wait "$task_id" 0 | grep -q '^VERDICT:'
  CLAUDE_BRIDGE_DRY_RUN=1 FRANK_BRIDGE_ARTIFACT_ROOT="$ARTIFACT_ROOT" "$BRIDGE" read "$task_id" | grep -q '^EVIDENCE:'
  python3 - "$ARTIFACT_ROOT/$task_id/metadata.json" "$task_id" <<'PY'
import json, sys
data = json.load(open(sys.argv[1], encoding="utf-8"))
assert data["task_id"] == sys.argv[2]
assert data["status"] == "done"
assert data["response_status"] == "parsed"
assert data["role"] == "reviewer"
PY
  [[ -z "$(find "$ARTIFACT_ROOT/$task_id" -name '*.tmp.*' -print -quit)" ]]
done

for invalid_task_id in . .. -option; do
  for invalid_command in wait read cleanup; do
    set +e
    CLAUDE_BRIDGE_DRY_RUN=1 FRANK_BRIDGE_ARTIFACT_ROOT="$ARTIFACT_ROOT" "$BRIDGE" "$invalid_command" "$invalid_task_id" >/dev/null 2>&1
    invalid_rc=$?
    set -e
    [[ "$invalid_rc" -eq 1 ]]
  done
done

before="$(find "$ARTIFACT_ROOT" -type f | wc -l | tr -d ' ')"
CLAUDE_BRIDGE_DRY_RUN=1 FRANK_BRIDGE_ARTIFACT_ROOT="$ARTIFACT_ROOT" "$BRIDGE" status | grep -q 'tasks=2'
after="$(find "$ARTIFACT_ROOT" -type f | wc -l | tr -d ' ')"
[[ "$before" == "$after" ]]

fixed="fixed-task-id"
CLAUDE_BRIDGE_DRY_RUN=1 FRANK_BRIDGE_DRY_RUN_TASK_ID="$fixed" FRANK_BRIDGE_ARTIFACT_ROOT="$ARTIFACT_ROOT" "$BRIDGE" send first >/dev/null
original_hash="$(python3 -c 'import hashlib,sys; print(hashlib.sha256(open(sys.argv[1],"rb").read()).hexdigest())' "$ARTIFACT_ROOT/$fixed/request.md")"
set +e
CLAUDE_BRIDGE_DRY_RUN=1 FRANK_BRIDGE_DRY_RUN_TASK_ID="$fixed" FRANK_BRIDGE_ARTIFACT_ROOT="$ARTIFACT_ROOT" "$BRIDGE" send overwritten >/dev/null 2>&1
collision_rc=$?
set -e
[[ "$collision_rc" -eq 1 ]]
current_hash="$(python3 -c 'import hashlib,sys; print(hashlib.sha256(open(sys.argv[1],"rb").read()).hexdigest())' "$ARTIFACT_ROOT/$fixed/request.md")"
[[ "$original_hash" == "$current_hash" ]]

deferred="deferred-task"
CLAUDE_BRIDGE_DRY_RUN=1 FRANK_BRIDGE_DRY_RUN_TASK_ID="$deferred" FRANK_BRIDGE_DRY_RUN_DEFER_RESPONSE=1 FRANK_BRIDGE_ARTIFACT_ROOT="$ARTIFACT_ROOT" "$BRIDGE" send pending >/dev/null
set +e
CLAUDE_BRIDGE_DRY_RUN=1 FRANK_BRIDGE_ARTIFACT_ROOT="$ARTIFACT_ROOT" "$BRIDGE" wait "$deferred" 0 >/dev/null 2>&1
timeout_rc=$?
set -e
[[ "$timeout_rc" -eq 2 ]]

noop_root="$TMPROOT/noop"
CLAUDE_BRIDGE_DRY_RUN=1 FRANK_BRIDGE_ARTIFACT_ROOT="$noop_root" "$BRIDGE" start >/dev/null
CLAUDE_BRIDGE_DRY_RUN=1 FRANK_BRIDGE_ARTIFACT_ROOT="$noop_root" "$BRIDGE" stop >/dev/null
[[ ! -e "$noop_root" ]]

concurrent_root="$TMPROOT/concurrent"
(
  CLAUDE_BRIDGE_DRY_RUN=1 FRANK_BRIDGE_ARTIFACT_ROOT="$concurrent_root" "$BRIDGE" send one >"$TMPROOT/send-one"
) &
pid_one=$!
(
  CLAUDE_BRIDGE_DRY_RUN=1 FRANK_BRIDGE_ARTIFACT_ROOT="$concurrent_root" "$BRIDGE" send two >"$TMPROOT/send-two"
) &
pid_two=$!
wait "$pid_one" "$pid_two"
concurrent_count="$(find "$concurrent_root" -mindepth 1 -maxdepth 1 -type d | wc -l | tr -d ' ')"
[[ "$concurrent_count" -eq 2 ]]

mixed_root="$TMPROOT/mixed"
mkdir -p "$mixed_root/live-task"
printf 'MODE=live\n' >"$mixed_root/live-task/session.env"
mixed_task="$(CLAUDE_BRIDGE_DRY_RUN=1 FRANK_BRIDGE_ARTIFACT_ROOT="$mixed_root" "$BRIDGE" send mixed | sed -n 's/^Task sent: task_id=//p')"
CLAUDE_BRIDGE_DRY_RUN=1 FRANK_BRIDGE_ARTIFACT_ROOT="$mixed_root" "$BRIDGE" cleanup --all >/dev/null
[[ -d "$mixed_root/live-task" && ! -e "$mixed_root/$mixed_task" ]]
[[ -f "$mixed_root/.frank-bridge-root" ]]
CLAUDE_BRIDGE_DRY_RUN=1 FRANK_BRIDGE_ARTIFACT_ROOT="$mixed_root" "$BRIDGE" cleanup --all >/dev/null
[[ -d "$mixed_root/live-task" && -f "$mixed_root/.frank-bridge-root" ]]
set +e
CLAUDE_BRIDGE_DRY_RUN=1 FRANK_BRIDGE_ARTIFACT_ROOT="$mixed_root" "$BRIDGE" cleanup live-task >/dev/null 2>&1
live_cleanup_rc=$?
set -e
[[ "$live_cleanup_rc" -eq 1 && -d "$mixed_root/live-task" ]]

CLAUDE_BRIDGE_DRY_RUN=1 FRANK_BRIDGE_ARTIFACT_ROOT="$ARTIFACT_ROOT" "$BRIDGE" cleanup "$task_a" >/dev/null
[[ ! -e "$ARTIFACT_ROOT/$task_a" ]]
CLAUDE_BRIDGE_DRY_RUN=1 FRANK_BRIDGE_ARTIFACT_ROOT="$ARTIFACT_ROOT" "$BRIDGE" cleanup --all >/dev/null
[[ ! -e "$ARTIFACT_ROOT" ]]

echo "bridge lifecycle test passed"
