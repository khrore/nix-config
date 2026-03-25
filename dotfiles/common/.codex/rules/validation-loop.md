# Validation Loop Rules

Default verification order:

1. formatter
2. linter
3. type or LSP-equivalent
4. build or compile
5. targeted tests
6. broader tests when required by risk or scope

Failure classes:
- `introduced`
- `pre_existing`
- `environment`
- `scope_expanding`

Rules:
- Self-fix only introduced failures inside the approved write set.
- Report pre-existing failures separately from introduced failures.
- Escalate repeated unchanged failures, environment blockers, and scope-expanding fixes.
- Do not skip a check silently.
