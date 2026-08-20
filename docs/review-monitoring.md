# Review Monitoring

Monitors reviewer health from submission to completion. Prevents silent reviewer hangs from blocking the workflow.

## Problem

After `bridge send`, the only feedback mechanism was `bridge wait` with a flat timeout. If a reviewer process hung mid-work, the caller waited the full timeout before discovering the failure — no receipt confirmation, no periodic checks, no early stale detection.

## Components

### Heartbeat file

Reviewers write `heartbeat` (ISO 8601 UTC timestamp) in the task directory:

- **On receipt**: immediately after accepting the request
- **During work**: every 30 seconds
- **Written via**: `frank_atomic_write` (tmp + mv) to prevent partial reads

### `review-monitor` script

```bash
bridges/lib/review-monitor <artifact-root> <task-id> [options]
```

Options:
- `--receipt-timeout N` — seconds to wait for first heartbeat (default 30)
- `--check-interval N` — seconds between health checks (default 60)
- `--stale-threshold N` — max heartbeat age before declaring stale (default 300)

Exit codes:
| Code | Meaning |
|---:|---|
| 0 | `response.md` arrived with valid verdict |
| 2 | Receipt timeout — reviewer never started |
| 3 | Reviewer stale — heartbeat expired mid-review |

### `bridge health` command

```bash
bridge health <task-id>
```

Returns a single line: `alive|stale|dead|done` with age and heartbeat metadata.

## Recovery

On stale (exit 3):
1. Terminate the hung reviewer process
2. Fall back to the next reviewer in the chain (Codex → Grok → Claude)
3. If all reviewers fail, escalate to Human

## Edge Cases

- **Partial writes**: heartbeat uses `frank_atomic_write`; readers never see truncated timestamps
- **Clock drift**: `frank_check_heartbeat` uses local `date(1)` for both write and read — no cross-host comparison
- **One reviewer per task**: `send` uses `mkdir` for collision prevention; heartbeat ownership follows task ownership
- **Heartbeat deleted**: treated as stale (same recovery path)
