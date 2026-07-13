# Commands

```bash
./scripts/check-env.sh
./scripts/secret-scan.sh
./scripts/docs-lint.sh
./tests/run.sh
./tests/bridge-lifecycle-test.sh
./tests/capacity-guard-test.sh
```

Reviewer dry-run lifecycle:

```bash
out=$(CLAUDE_BRIDGE_DRY_RUN=1 bridges/claude/claude-official-bridge send templates/review-request.md)
task_id=$(printf '%s\n' "$out" | sed -n 's/^Task sent: task_id=//p')
CLAUDE_BRIDGE_DRY_RUN=1 bridges/claude/claude-official-bridge wait "$task_id" 5
CLAUDE_BRIDGE_DRY_RUN=1 bridges/claude/claude-official-bridge read "$task_id"
CLAUDE_BRIDGE_DRY_RUN=1 bridges/claude/claude-official-bridge cleanup "$task_id"
```
