# Bridge Protocol v0.2

The protocol is vendor-neutral. Claude, Codex, and Gemini are adapters; live clients remain external to this repository.

## Lifecycle

```text
bridge start
bridge send <prompt-or-file>        # prints Task sent: task_id=<id>
bridge wait <task-id> [timeout]
bridge read <task-id>
bridge health <task-id>              # heartbeat-based status check
bridge status                       # must not create artifacts
bridge stop
bridge cleanup <task-id|--all>
```

The Claude dry-run adapter is the v0.2 reference implementation. `start` and `stop` are no-op successes in dry-run. Codex and Gemini lifecycle parity is planned for v0.2.1; their v0.2 dry-run `status` compatibility remains intact.

## Task and Artifact Contract

Default task ids use `YYYYMMDDTHHMMSSZ-<pid>-<8 hex>` with entropy from `/dev/urandom`. Tests may set `FRANK_BRIDGE_DRY_RUN_TASK_ID`; reusing an existing id fails with exit `1` and never overwrites artifacts.

The reviewer reference adapter writes:

```text
.claude-bridge/<task-id>/
  request.md
  session.env
  response.md
  metadata.json
```

- Task directories and files are user-only where the platform permits.
- `response.md` and `metadata.json` are written to temporary files in the same directory and committed with same-filesystem `mv`.
- `wait` succeeds only when `response.md` contains a valid verdict.
- `response.md` is the completion source of truth. A crash after committing it but before the final metadata update can leave `metadata.json` at `pending`; readers must not treat that stale status as an incomplete response.
- `request.md` can contain sensitive prompt text. Artifact roots are ignored by Git but are not a secret store; run `cleanup` when retention is unnecessary. `cleanup --all` removes only tasks marked `MODE=dry-run` and leaves external live-adapter tasks untouched.
- `status` is read-only.

Live adapters should archive equivalent evidence even if their runtime root differs.

## Heartbeat Contract

Reviewers write a `heartbeat` file in the task directory immediately upon receiving a request and update it every 30 seconds. The file contains a single ISO 8601 UTC timestamp written via `frank_atomic_write` to prevent partial reads.

The `health` command reads the heartbeat and returns a single machine-parsable line:

```text
alive age=45s last_heartbeat=12s    # reviewer is active
stale age=320s last_heartbeat=310s  # heartbeat expired (default threshold: 300s)
dead  age=600s no_heartbeat         # no heartbeat ever written
done  age=180s                      # response.md present with valid verdict
```

The companion `review-monitor` script automates three-phase monitoring: receipt confirmation (heartbeat appears within 30s), periodic health checks (every 60s), and stale detection (heartbeat age exceeds threshold). See `docs/review-monitoring.md`.

## Verdict Contract

```text
VERDICT: APPROVED | APPROVED_WITH_RISKS | REVISE
FINDINGS:
RECOMMENDATIONS:
EVIDENCE:
```

Any blocking finding means `REVISE`. An approval is valid only for the reviewed tree or declared diff. A tracked change in reviewed scope invalidates the prior approval and requires re-review.

## Exit Codes

| Exit | Meaning | Workflow action |
|---:|---|---|
| `0` | Success | Continue. |
| `1` | Invalid arguments, unknown task, invalid artifact, or general failure | Fix locally; do not ask by default. |
| `2` | Wait timeout | Diagnose and retry within the infrastructure budget. |
| `74` | Partial execution or unknown replay safety | Do not replay. Reconcile state and report to the human before another attempt. |
| `75` | Capacity exhausted with replay safety proven `none` | Back off or use another known-safe fallback; not a user approval gate. |
| `124` | Required external client missing | Repair environment or select another compatible adapter. |

Exit `74` is an infrastructure code, not a human approval choice. Its partial/unknown execution state is nevertheless a workflow hard stop because another attempt could duplicate side effects.

## Concurrency

Each `send` owns one unique task directory. Dry-run adapters use no global mutable current-task pointer. A deterministic test id collision fails closed. Live adapters may use workspace locks, but independent tasks must retain distinct ids and artifacts.

## Capacity Contract

Capacity and overload are transient infrastructure states, not task failures or user gates. The optional `bridges/lib/capacity-guard` follows these rules:

1. Exit `0` always wins, even if normal output mentions capacity.
2. Non-capacity failures keep the child exit code and are never retried.
3. Replay requires a structured probe returning `none` or `FRANK_CAPACITY_IDEMPOTENT=1`.
4. A probe reporting `present` or `unknown` returns `74`; with no probe or explicit idempotent declaration, any capacity failure returns `74` without replay.
5. Known-safe exhausted fallbacks return `75`.

Default classification is deliberately fail-closed and matches exact capacity-style stderr lines. Providers with structured errors should supply `FRANK_CAPACITY_CLASSIFIER` rather than broadening the public default.
