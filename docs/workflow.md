# Workflow

## Execution Principle

Keep work moving until it is complete or a real hard stop is reached. Progress reports are not pause points. Ordinary review feedback, test failures, lint failures, and low-risk implementation choices are handled automatically.

## Compact Path

```text
Inspect -> Minimal change -> Local QA -> Independent review -> Report
```

## Full Gated Path

```text
Research -> Design packet -> Pre-dev review -> Implement -> QA
  -> Post-dev review -> Commit/PR -> Optional deploy gate -> Closeout
```

Use the full path for schema/migration, auth, payments, deployment, cross-service contracts, concurrency, retries, caches, or other medium/high-risk work. For paths exceeding three implementation steps, use Document-Anchored Development (DAD) to prevent goal drift. See `docs/document-anchored-development.md`.

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
Scout -> Split independent tasks -> Developer workers -> Independent reviewer
  -> Fix -> Lead merge -> QA -> Final review
```

Advisory agents do not approve code. The implementation author cannot be the final reviewer.
