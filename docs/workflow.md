# Workflow

## Execution Principle

Keep work moving until it is complete or a real hard stop is reached. Progress reports are not pause points. Ordinary review feedback, test failures, lint failures, and low-risk implementation choices are handled automatically.

## Compact Path

```text
Inspect -> Minimal change -> Local QA -> Independent review -> Report
```

## Full Gated Path

```text
Research -> Design packet [-> create design doc] -> Pre-dev review -> Implement
  [-> update design doc after each step; re-read before next step]
  -> QA -> Post-dev review -> Commit/PR -> Optional deploy gate -> Closeout
```

Use the full path for schema/migration, auth, payments, deployment, cross-service contracts, concurrency, retries, caches, or other medium/high-risk work.

### Document-Anchored Development (DAD)

For paths exceeding three implementation steps, a living design document is **required** throughout execution. See `docs/document-anchored-development.md` for full rules.

Integrated steps:

1. **Design packet stage**: create `/tmp/<project>-design/design-doc.md` from `templates/design-doc.md` with goals, boundaries, and approach
2. **Before each implementation step**: re-read the design doc; confirm the step aligns with goals
3. **After each implementation step**: update the doc — mark completed, record findings, correct direction if needed
4. **On agent handoff**: pass the document path; receiving agent reads before working
5. **After context compact**: first action is re-reading the design doc, not working from memory
6. **Post-dev review**: include the design doc as evidence of goal alignment

## Continuous Execution

Auto-proceed without asking the user for:

- a normal `REVISE` while the review-round budget remains;
- unit, integration, lint, docs, or build failures that can be fixed inside scope;
- advisory scout feedback;
- reversible local tests and disposable fixtures;
- capacity exit `75` when replay is known safe;
- a new review required because the reviewed diff changed.

Every code, config, migration, workflow, or generated-contract change invalidates the previous code review. Fix, rerun QA, and review the latest diff.

## Hard Stops

Stop and escalate only for:

- production deploy, cutover, or traffic changes;
- real funds, mainnet, or paid resource consumption;
- secret, credential, authentication, or permission changes;
- destructive or irreversible operations;
- files or systems outside the approved scope;
- a discovery that invalidates the design;
- a new unreviewed dependency with material trust impact;
- exhausted review budgets (default two design/final rounds, three heavy implementation rounds);
- exit `74`, because execution may be partial or replay safety is unknown.

Exit `74` does not ask the human to approve an infrastructure error. It requires state reconciliation and a human decision before any new attempt.

## Multi-agent Path

```text
Scout -> Split independent tasks [-> pass design doc path to each worker]
  -> Developer workers [-> re-read design doc before starting; update after each milestone]
  -> Independent reviewer -> Fix -> Lead merge -> QA -> Final review
```

Advisory agents do not approve code. The implementation author cannot be the final reviewer. On every agent handoff, the design document path must be passed; the receiving agent reads it before working.
