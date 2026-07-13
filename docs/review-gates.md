# Review Gates

Review gates separate implementation from evaluation. The reviewer must be independent of the change author.

## Pre-development

For medium/high-risk work, review a design packet containing scope, non-goals, runtime evidence, decision alternatives, file domains, risks, tests, migration, and rollback. Blocking design findings must be resolved before implementation.

## Post-development

The reviewer receives:

- the exact current diff or commit/tree reference;
- local QA commands, exit codes, and decisive output;
- docs and compatibility impact;
- rollback posture;
- prior blocking findings and how they were closed.

Any blocking finding produces `REVISE`. Suggestions are advisory and may be accepted or declined with rationale.

## Invalidation

Approval is bound to its review basis. Any later tracked change in reviewed scope invalidates it, including a fix requested by review or a whitespace-only change. Run QA as needed and review the latest diff again before claiming the gate passed.

## Automatic Revision

Within the configured round budget, `REVISE` flows directly back to implementation and re-review. It is not a user confirmation point. Default budgets are two rounds for design/final gates and three for heavy implementation checkpoints.

## Human Gates

Human approval is reserved for production, destructive, irreversible, financial, secret/permission, scope-breaking, or design-invalidating decisions. Capacity/timeout errors are infrastructure states; only partial or unknown execution (exit `74`) creates a hard stop before replay.

## Evidence

Archive task id, request, response, session metadata, review basis, and QA evidence. A dry-run verdict proves protocol plumbing only; it never substitutes for a real independent code review.
