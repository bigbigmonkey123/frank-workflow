#!/usr/bin/env bash
set -euo pipefail
LIVE=0
if [[ "${1:-}" == "--live" ]]; then
  LIVE=1
elif [[ "${1:-}" == "--help" || "${1:-}" == "-h" ]]; then
  cat <<'USAGE'
Usage: scripts/check-env.sh [--live]

Default checks only the minimum framework requirements.
--live also checks optional live adapter/runtime tools expected outside this repo.
USAGE
  exit 0
fi

echo "Frank Workflow env check"
missing=0
for c in bash git python3; do
  if command -v "$c" >/dev/null 2>&1; then
    echo "OK required: $c"
  else
    echo "missing required: $c" >&2
    missing=1
  fi
done

if [[ "$LIVE" == "1" ]]; then
  echo "Live adapter checks"
  for c in claude codex gemini tmux tmux-bridge gitleaks shellcheck; do
    if command -v "$c" >/dev/null 2>&1; then
      echo "OK optional: $c ($(command -v "$c"))"
    else
      echo "WARN optional missing: $c"
    fi
  done
  for var in CLAUDE_BRIDGE_BIN CODEX_BRIDGE_BIN GEMINI_BRIDGE_BIN TMUX_BIN TMUX_BRIDGE_BIN; do
    if [[ -n "${!var:-}" ]]; then
      echo "OK env override: $var=${!var}"
    fi
  done
fi

if [[ "$missing" != "0" ]]; then
  exit 1
fi
echo "OK"
