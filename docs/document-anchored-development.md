# Document-Anchored Development (DAD)

Prevents goal drift in long conversations and multi-agent workflows by anchoring all work to a living design document.

## Problem

Context compaction (compression) in long AI conversations causes agents to gradually forget original goals, boundaries, and prior decisions. In multi-agent workflows, each handoff loses context. After several steps or handoffs, the final output can diverge significantly from the original intent.

## Solution

Maintain a single design document throughout the workflow. Every agent reads it before starting, updates it after each step, and passes it to the next agent. The document is the persistent source of truth that survives context compression and agent transitions.

## Five Rules

1. **Before starting**: create the design doc from `templates/design-doc.md` with goals, boundaries, and approach
2. **After each step**: update the doc — mark completed, record findings, correct direction if needed
3. **Before each step**: re-read the doc, confirm the next step still aligns with goals
4. **On agent handoff**: pass the document path; receiving agent reads before working
5. **After context compact**: first action is re-reading the design doc

## Document Structure

| Section | Purpose |
|---------|---------|
| Goals | Checkboxes — what success looks like |
| Boundaries / Non-goals | What is explicitly out of scope |
| Approach | High-level direction and key decisions |
| Steps | Ordered task list with checkboxes |
| Progress Log | Append-only table: step, status, findings, direction changes |
| Open Questions | Unresolved items that may affect direction |

## Path Convention

```
/tmp/<project>-design/design-doc.md
```

Follows the existing pattern of `/tmp/<project>-pm/`, `/tmp/<project>-review/`, etc.

## When to Use

| Scenario | DAD Required? |
|----------|--------------|
| Full Gated Path, >3 implementation steps | Strongly recommended |
| Multi-agent collaboration | Strongly recommended |
| Expected long conversation (compact likely) | Recommended |
| Compact Path | Encouraged, not required |
| Pure query / diagnostics | Not needed |

## Integration with Full Gated Path

In the Full Gated Path, the design packet created during PM analysis serves as the initial design document. During implementation:

1. Developer reads the design doc before each milestone
2. After each milestone, developer updates Progress Log with findings
3. If direction changes, developer updates Approach and notes the reason
4. Post-dev review includes the design doc as evidence of goal alignment

## Anti-drift Rules

- An agent starting work must cite the design doc's current goals
- Work that doesn't align with documented goals must either be corrected or the goals updated (with justification recorded in Progress Log)
- After context compact, the agent's first action is re-reading the design doc — working from memory alone is not permitted
