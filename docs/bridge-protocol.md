# Bridge Protocol

## Lifecycle

```text
bridge start
bridge send <prompt-or-file>
bridge wait <task-id> [timeout]
bridge read [task-id|lines]
bridge status
bridge stop
bridge cleanup
```

## Verdict Contract

```text
VERDICT: APPROVED | APPROVED_WITH_RISKS | REVISE
FINDINGS:
RECOMMENDATIONS:
EVIDENCE:
```

## Exit Codes

| Exit code | Meaning |
|---:|---|
| 0 | Success. |
| 1 | General error. |
| 2 | Timeout. |
| 124 | Required bridge/client binary not found. |

`send` prints a task id on success. `wait` returns `2` on timeout. `status` must not create side effects.
