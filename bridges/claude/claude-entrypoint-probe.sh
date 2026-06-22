#!/usr/bin/env bash
set -euo pipefail
if [[ "${CLAUDE_BRIDGE_DRY_RUN:-0}" == "1" ]]; then
  echo '{"dry_run":true,"entrypoint":"cli"}'
  exit 0
fi
echo "error: live entrypoint probe is not bundled in v0.1" >&2
exit 124
