#!/usr/bin/env bash
set -euo pipefail
# Generic public-release denylist. Do not commit private project names or
# infrastructure hints into this scanner; teams may layer an external denylist
# in CI through EXTRA_SECRET_SCAN_DENYLIST.
PATTERN='(/Users/[A-Za-z0-9._-]+|/home/[A-Za-z0-9._-]+|C:\\Users\\[A-Za-z0-9._-]+|[0-9]{1,3}(\.[0-9]{1,3}){3}|(api[_-]?key|token|secret|password)\s*[:=]\s*[^[:space:]]{8,})'
scan() {
  local pattern="$1"
  grep -RInE "$pattern" \
    --exclude-dir=.git \
    --exclude-dir=.claude-bridge \
    --exclude='.gitleaks.toml' \
    --exclude='secret-scan.sh' \
    . || true
}
hits="$(scan "$PATTERN")"
if [[ -n "${EXTRA_SECRET_SCAN_DENYLIST:-}" ]]; then
  if [[ ! -f "$EXTRA_SECRET_SCAN_DENYLIST" ]]; then
    echo "missing EXTRA_SECRET_SCAN_DENYLIST: $EXTRA_SECRET_SCAN_DENYLIST" >&2
    exit 1
  fi
  while IFS= read -r pattern; do
    [[ -z "$pattern" || "$pattern" == \#* ]] && continue
    extra_hits="$(scan "$pattern")"
    [[ -n "$extra_hits" ]] && hits+=$'\n'"$extra_hits"
  done < "$EXTRA_SECRET_SCAN_DENYLIST"
fi
if [[ -n "$hits" ]]; then
  printf '%s\n' "$hits"
  echo "secret/private marker scan failed" >&2
  exit 1
fi
echo "secret scan clean"
