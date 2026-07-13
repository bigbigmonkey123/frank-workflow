# AGENTS.md

<!-- generated or copied from Frank Workflow -->

## Persona

{{PERSONA_RULES}}

## Workflow

Use the compact path for low-risk changes and the full gated path for medium/high-risk changes.

- Continue automatically through ordinary test fixes, documentation fixes, and review revisions while the round budget remains.
- Ask only for production, destructive, irreversible, financial, secret/permission, scope-breaking, design-invalidating, or exhausted-gate decisions.
- Capacity/overload is an infrastructure state, not a user confirmation point. Never replay after partial or unknown execution without reconciliation.

## Review

Use bridge protocol verdicts: APPROVED, APPROVED_WITH_RISKS, REVISE.

Any tracked change in reviewed scope invalidates the previous approval. Review the latest diff before delivery.
