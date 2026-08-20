#!/usr/bin/env bash

# Shared dry-run artifact helpers. Callers must enable their own strict mode.

frank_validate_task_id() {
  case "${1:-}" in
    ''|.|..|-*|*[!A-Za-z0-9._-]*) return 1 ;;
    *) return 0 ;;
  esac
}

frank_generate_task_id() {
  if [[ -n "${FRANK_BRIDGE_DRY_RUN_TASK_ID:-}" ]]; then
    frank_validate_task_id "$FRANK_BRIDGE_DRY_RUN_TASK_ID" || {
      echo "error: invalid FRANK_BRIDGE_DRY_RUN_TASK_ID" >&2
      return 1
    }
    printf '%s\n' "$FRANK_BRIDGE_DRY_RUN_TASK_ID"
    return 0
  fi

  local random_hex
  random_hex="$(od -An -N4 -tx1 /dev/urandom | tr -d ' \n')"
  [[ ${#random_hex} -eq 8 ]] || {
    echo "error: unable to generate task-id entropy" >&2
    return 1
  }
  printf '%s-%s-%s\n' "$(date -u +%Y%m%dT%H%M%SZ)" "$$" "$random_hex"
}

frank_ensure_artifact_root() {
  local root="$1"
  umask 077
  mkdir -p "$root"
  chmod 700 "$root" 2>/dev/null || true
  : >"$root/.frank-bridge-root"
}

frank_atomic_write() {
  local destination="$1"
  local directory base temporary
  directory="$(dirname "$destination")"
  base="$(basename "$destination")"
  temporary="$directory/.${base}.tmp.$$"
  cat >"$temporary"
  mv "$temporary" "$destination"
}

frank_write_heartbeat() {
  local task_dir="$1"
  date -u +%Y-%m-%dT%H:%M:%SZ | frank_atomic_write "$task_dir/heartbeat"
}

# Returns heartbeat age in seconds; -1 if no heartbeat file exists.
# Relies on local date(1) monotonicity — no cross-host clock sync assumed.
frank_check_heartbeat() {
  local task_dir="$1"
  local hb_file="$task_dir/heartbeat"
  [[ -f "$hb_file" ]] || { echo "-1"; return 0; }
  local hb_ts now_ts
  hb_ts="$(cat "$hb_file")"
  if date -j -u -f "%Y-%m-%dT%H:%M:%SZ" "$hb_ts" +%s >/dev/null 2>&1; then
    hb_ts="$(date -j -u -f "%Y-%m-%dT%H:%M:%SZ" "$hb_ts" +%s)"
  else
    hb_ts="$(date -d "$hb_ts" +%s 2>/dev/null || echo 0)"
  fi
  now_ts="$(date -u +%s)"
  echo $(( now_ts - hb_ts ))
}

frank_write_metadata() {
  local destination="$1" task_id="$2" status="$3" response_status="$4"
  local role="$5" created_at="$6" finished_at="${7:-}"
  python3 - "$destination" "$task_id" "$status" "$response_status" "$role" "$created_at" "$finished_at" <<'PY'
import json
import os
import sys

destination, task_id, status, response_status, role, created_at, finished_at = sys.argv[1:]
payload = {
    "task_id": task_id,
    "status": status,
    "response_status": response_status,
    "role": role,
    "mode": "dry-run",
    "created_at": created_at,
    "finished_at": finished_at or None,
}
temporary = os.path.join(os.path.dirname(destination), ".metadata.json.tmp.%s" % os.getpid())
with open(temporary, "w", encoding="utf-8") as stream:
    json.dump(payload, stream, indent=2, sort_keys=True)
    stream.write("\n")
os.replace(temporary, destination)
PY
}
