# Workflow Failure Taxonomy

Use these classes when reporting validation or execution failures in workflow stages.

## Classes

- `introduced`: caused by the current change set and must be fixed before handoff.
- `pre-existing`: already present before the current change set and should be reported with blocking impact if confidence is reduced.
- `environment`: caused by missing tools, infrastructure, permissions, or runtime environment issues.
- `scope-expanding`: cannot be fixed without edits outside the approved scope or write set.

## Reporting Rules

- Classify each failed check using exactly one class.
- Include the failing command, the observed symptom, and why the class was chosen.
- Escalate when `pre-existing`, `environment`, or `scope-expanding` failures prevent reliable validation.
