#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TMPROOT="$(mktemp -d "${TMPDIR:-/tmp}/frank-delegation-test.XXXXXX")"
cleanup() { rm -rf "$TMPROOT"; }
trap cleanup EXIT

cat >"$TMPROOT/external" <<'FAKE'
#!/usr/bin/env bash
printf 'delegated:%s\n' "$*"
FAKE
chmod +x "$TMPROOT/external"

CLAUDE_BRIDGE_BIN="$TMPROOT/external" "$ROOT/bridges/claude/claude-official-bridge" status detail | grep -q '^delegated:status detail$'
CODEX_BRIDGE_BIN="$TMPROOT/external" "$ROOT/bridges/codex/codex-bridge" status detail | grep -q '^delegated:status detail$'
GEMINI_BRIDGE_BIN="$TMPROOT/external" "$ROOT/bridges/gemini/gemini-bridge" status detail | grep -q '^delegated:status detail$'

echo "live delegation test passed"
