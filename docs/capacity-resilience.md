# Capacity Resilience

`bridges/lib/capacity-guard` is a vendor-neutral wrapper for non-interactive commands that can fail because a selected backend is at capacity.

## Safe Defaults

- No fallback is configured by default. Without a probe or explicit idempotent declaration, replay safety remains unknown and a capacity failure returns `74`.
- The default classifier matches exact capacity-style stderr lines and fails closed on unfamiliar formats.
- A fallback is called only when replay is explicitly idempotent/read-only or a side-effect probe reports `none`.
- A configured probe reporting `present` or `unknown` returns `74`. Without a probe or explicit idempotent declaration, replay safety is unknown and the guard returns `74` without replay.
- A classified capacity failure returns `75` only when replay safety is proven `none` and no fallback remains.
- Non-capacity failures retain their original exit code.

## Usage

```bash
bridges/lib/capacity-guard -- primary-adapter --flag value
```

Fallback executables receive the primary executable's original arguments:

```bash
FRANK_CAPACITY_IDEMPOTENT=1 \
FRANK_CAPACITY_FALLBACK_BINS='/path/to/fallback-a:/path/to/fallback-b' \
bridges/lib/capacity-guard -- /path/to/primary request.json
```

For non-idempotent commands, configure `FRANK_SIDE_EFFECT_PROBE`. It receives the captured stdout and stderr paths and must print exactly `none`, `present`, or `unknown`.

Provider-specific structured errors should use `FRANK_CAPACITY_CLASSIFIER`. It receives stdout and stderr paths and returns `0` only for a genuine capacity failure.

Artifacts under `.frank-capacity-guard/` contain attempt number, result class, and exit code only. Prompt arguments and raw output remain in a temporary directory removed on normal exit; an uncatchable process kill can leave temporary files for operating-system cleanup.

## Upgrade Rule

After upgrading an adapter or CLI, rerun `tests/capacity-guard-test.sh` and a safe real smoke. Event or error-schema changes must not silently weaken replay protection.
