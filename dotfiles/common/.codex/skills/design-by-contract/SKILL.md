---
name: design-by-contract
description: Apply Design by Contract while generating, refactoring, or reviewing code in mixed-language or config-heavy repos. Use when boundaries need clearer guarantees, validation, failure behavior, or compatibility rules for adapters and overrides.
---

# Design by Contract

Apply this skill when generating, reviewing, or shaping boundaries in a mixed-language or configuration-heavy repo.

- State preconditions, postconditions, and invariants.
- Review boundary validation, failure modes, contract enforcement, and compatibility of overrides and adapters.
- Prefer executable contracts using types, assertions, schemas, and tests where possible.

When reviewing:

- Check that inputs are validated at the boundary before side effects occur.
- Check that success conditions and outputs are explicit after transformations, writes, or provisioning steps.
- Check that invariants remain true across refactors, retries, and partial failures.
- Flag adapters or overrides that require more, promise less, or change failure behavior incompatibly.

When proposing changes:

- Add guard clauses, assertions, schema checks, or types that encode the contract.
- Add targeted tests for important preconditions, postconditions, and invariants.
- Make failure paths early, explicit, and deterministic.
- Document non-obvious contracts only when code cannot express them directly.
