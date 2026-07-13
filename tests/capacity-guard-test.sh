#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
GUARD="$ROOT/bridges/lib/capacity-guard"
TMPROOT="$(mktemp -d "${TMPDIR:-/tmp}/frank-capacity-test.XXXXXX")"
cleanup() { rm -rf "$TMPROOT"; }
trap cleanup EXIT

cat >"$TMPROOT/primary" <<'FAKE'
#!/usr/bin/env bash
printf 'primary\n' >>"$FAKE_LOG"
case "$FAKE_MODE" in
  capacity) echo 'Selected model is at capacity. Please try a different model.' >&2; exit 1 ;;
  noncapacity) echo 'authentication failed' >&2; exit 42 ;;
  banner_success) echo 'Selected model is at capacity. Please try a different model.'; exit 0 ;;
esac
FAKE
cat >"$TMPROOT/fallback" <<'FAKE'
#!/usr/bin/env bash
printf 'fallback\n' >>"$FAKE_LOG"
printf 'fallback-success:%s\n' "${1:-}"
FAKE
cat >"$TMPROOT/probe-present" <<'PROBE'
#!/usr/bin/env bash
echo present
PROBE
cat >"$TMPROOT/probe-unknown" <<'PROBE'
#!/usr/bin/env bash
echo unknown
PROBE
cat >"$TMPROOT/probe-none" <<'PROBE'
#!/usr/bin/env bash
echo none
PROBE
chmod +x "$TMPROOT/primary" "$TMPROOT/fallback" "$TMPROOT/probe-present" "$TMPROOT/probe-unknown" "$TMPROOT/probe-none" "$GUARD"

export FAKE_LOG="$TMPROOT/invocations"
export FRANK_CAPACITY_ARTIFACT_ROOT="$TMPROOT/artifacts"
export FRANK_CAPACITY_BACKOFF_SECONDS=0

: >"$FAKE_LOG"
out="$(FAKE_MODE=capacity FRANK_SIDE_EFFECT_PROBE="$TMPROOT/probe-none" FRANK_CAPACITY_FALLBACK_BINS="$TMPROOT/fallback" "$GUARD" -- "$TMPROOT/primary" secret-marker)"
[[ "$out" == 'fallback-success:secret-marker' ]]
[[ "$(paste -sd, "$FAKE_LOG")" == 'primary,fallback' ]]
if grep -R -q 'secret-marker' "$TMPROOT/artifacts"; then echo "capacity ledger leaked arguments" >&2; exit 1; fi

: >"$FAKE_LOG"
set +e
FAKE_MODE=capacity FRANK_SIDE_EFFECT_PROBE="$TMPROOT/probe-present" FRANK_CAPACITY_FALLBACK_BINS="$TMPROOT/fallback" "$GUARD" -- "$TMPROOT/primary" >/dev/null 2>&1
present_rc=$?
set -e
[[ "$present_rc" -eq 74 && "$(wc -l <"$FAKE_LOG" | tr -d ' ')" -eq 1 ]]

: >"$FAKE_LOG"
set +e
FAKE_MODE=capacity FRANK_CAPACITY_FALLBACK_BINS="$TMPROOT/fallback" "$GUARD" -- "$TMPROOT/primary" >/dev/null 2>&1
unknown_rc=$?
set -e
[[ "$unknown_rc" -eq 74 && "$(wc -l <"$FAKE_LOG" | tr -d ' ')" -eq 1 ]]

: >"$FAKE_LOG"
set +e
FAKE_MODE=capacity FRANK_CAPACITY_IDEMPOTENT=1 "$GUARD" -- "$TMPROOT/primary" >/dev/null 2>&1
exhausted_rc=$?
set -e
[[ "$exhausted_rc" -eq 75 && "$(wc -l <"$FAKE_LOG" | tr -d ' ')" -eq 1 ]]

: >"$FAKE_LOG"
set +e
FAKE_MODE=capacity "$GUARD" -- "$TMPROOT/primary" >/dev/null 2>&1
default_unknown_rc=$?
set -e
[[ "$default_unknown_rc" -eq 74 && "$(wc -l <"$FAKE_LOG" | tr -d ' ')" -eq 1 ]]

: >"$FAKE_LOG"
set +e
FAKE_MODE=capacity FRANK_SIDE_EFFECT_PROBE="$TMPROOT/probe-unknown" "$GUARD" -- "$TMPROOT/primary" >/dev/null 2>&1
probe_unknown_rc=$?
set -e
[[ "$probe_unknown_rc" -eq 74 && "$(wc -l <"$FAKE_LOG" | tr -d ' ')" -eq 1 ]]

: >"$FAKE_LOG"
set +e
FAKE_MODE=noncapacity FRANK_CAPACITY_IDEMPOTENT=1 FRANK_CAPACITY_FALLBACK_BINS="$TMPROOT/fallback" "$GUARD" -- "$TMPROOT/primary" >/dev/null 2>&1
noncapacity_rc=$?
set -e
[[ "$noncapacity_rc" -eq 42 && "$(wc -l <"$FAKE_LOG" | tr -d ' ')" -eq 1 ]]

: >"$FAKE_LOG"
FAKE_MODE=banner_success FRANK_CAPACITY_IDEMPOTENT=1 FRANK_CAPACITY_FALLBACK_BINS="$TMPROOT/fallback" "$GUARD" -- "$TMPROOT/primary" >/dev/null
[[ "$(wc -l <"$FAKE_LOG" | tr -d ' ')" -eq 1 ]]

echo "capacity guard test passed"
