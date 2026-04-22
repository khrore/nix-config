# AGENTS.md - Codex Policy Kernel

## Validation Minimums

For behavior-changing work, validate in this order when applicable:

1. formatter check
1. linter check
1. type or LSP-equivalent check
1. build or compile check
1. targeted tests for changed behavior
1. broader tests when risk or scope requires

Classify failures as one of:

- introduced
- pre-existing
- environment
- scope-expanding

Do not claim success without command evidence.

Linter warnings are not ignorable by default. Treat any linter warning on touched code as a failure that must be fixed or explicitly escalated with justification before handoff or completion.

## Design Review Heuristics

Use these as short programming rules when writing code, refactoring, and reviewing changes. Treat them as heuristics, not dogma. Prefer the smallest change that reduces coupling, drift, and surprise.

### SOLID

- Apply these to modules, functions, schemas, and provider boundaries, not only OO classes.
- `S`: give each unit one clear job and one main reason to change.
- `O`: extend behavior through new modules, adapters, or options before editing stable core code.
- `L`: make replacements work through the same contract without surprising callers.
- `I`: keep interfaces small and focused; do not force consumers to depend on things they do not use.
- `D`: depend on stable abstractions and contracts, not concrete tools, paths, SDKs, or environment details.

### Composition Over Inheritance (CRP)

- Prefer composing small helpers, modules, and adapters over deep inheritance trees.
- Use inheritance only when the subtype relationship is real and shared behavior is stable.
- Avoid fragile base classes, hierarchy sprawl, and reuse that only works through ancestry.

### DRY

- Keep one authoritative source for change-prone knowledge such as rules, defaults, schemas, versions, and paths.
- Remove repeated logic when it is likely to drift.
- Do not introduce brittle abstractions when a small local duplication is clearer and safer.

### KISS

- Choose the simplest design that satisfies the current requirement and is easy to inspect, debug, and repair.
- Avoid unnecessary indirection, magic behavior, and tools that are more complex than the problem.
- Keep boundaries obvious: config selects behavior, code implements behavior, scripts orchestrate.

### Law of Demeter

- Keep units talking to direct collaborators, not reaching deep through object graphs or layers.
- Reduce chaining, deep property access, and cross-boundary traversal when it increases coupling.
- Stay pragmatic for simple data transformations, but prefer clear boundaries over convenience.

### Design by Contract

- Make inputs, outputs, invariants, side effects, and error modes explicit at public boundaries.
- Encode contracts in types, assertions, schemas, and targeted tests when possible.
- Reject invalid states early and keep guarantees clear after the call returns.

### Encapsulation

- Keep state with the code that maintains it and limit direct access to internals.
- Do not let callers bypass validation or depend on private structure or incidental defaults.
- Keep exported surface area intentionally small.

### Command-Query Separation (CQS)

- Separate reads from writes where practical: queries return data, commands change state.
- Avoid hidden mutations in query-shaped APIs.
- When both are needed, prefer explicit pairs such as `plan/apply`, `validate/fix`, or `render/persist`.

### Principle of Least Astonishment (POLA)

- Make names, defaults, and behavior match local conventions and user expectations.
- Avoid hidden context and surprising side effects.
- If behavior is unusual but necessary, signal it clearly in naming, comments, and docs.

### Linguistic Modular Units

- Keep modules aligned with the language's natural units, such as files, functions, classes, packages, and schemas.
- Do not hide core behavior behind ad hoc structure when the language already provides a clear boundary.
- Make module boundaries easy to find and reason about in the codebase.

### Self-Documentation

- Write code so intent is visible from names, types, structure, and module layout before relying on comments.
- Use comments to explain why or note non-obvious constraints, not to restate the code.
- Keep examples, defaults, and contracts close to the code they describe.

### Uniform Access

- Expose similar capabilities through a consistent interface regardless of whether the result is stored or computed.
- Do not force callers to care about internal implementation details.
- Preserve stable calling patterns as implementations evolve.

### Single Choice

- Keep the exhaustive list of alternatives in one place.
- Centralize choice logic for modes, variants, providers, feature flags, and enum-like branching.
- Derive other behavior from that source instead of duplicating switch logic across the codebase.

### Persistence Closure

- When persisting an object or configuration, persist the dependent state needed to restore it correctly.
- When loading persisted state, restore required dependencies together or fail clearly.
- Avoid half-loaded state that appears valid but is missing necessary context.
