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

Use these principles when generating code, refactoring, and reviewing changes, not only after the fact. Treat them as heuristics, not dogma. Prefer the smallest change that reduces coupling, drift, and surprise.

### SOLID

- Treat `class` and `interface` loosely as any module, function boundary, schema, or provider contract.
- `S`: keep one reason to change per unit.
- `O`: prefer extension seams over repeated edits to stable core paths.
- `L`: replacements must preserve caller expectations without special-casing.
- `I`: keep APIs, options, and module surfaces narrow for each consumer.
- `D`: keep policy dependent on abstractions, not concrete tools, paths, SDKs, or host details.

### Composition Over Inheritance (CRP)

- Prefer `has-a` over `is-a` when sharing behavior.
- Use inheritance only for true subtype relationships with stable shared defaults.
- Review for fragile base classes, hierarchy explosion, and reuse achieved only through ancestry.
- In mixed repos, prefer small composed modules, helpers, and adapters over monolithic base layers.

### DRY

- Keep one authoritative representation for change-prone knowledge.
- Review repeated rules, versions, paths, schemas, defaults, and exhaustive option lists.
- Prefer derivation across code, config, CI, docs, and tests when churn is real.
- Do not force brittle abstractions when local duplication is clearer and cheaper to maintain.

### KISS

- Choose the simplest design that satisfies current requirements and is easy for an ordinary maintainer to inspect, debug, and repair.
- Review hidden behavior, unnecessary indirection, special cases, and tool choices that are more powerful than the problem requires.
- Keep boundaries obvious: config selects behavior, code implements behavior, scripts orchestrate.

### Law of Demeter

- A unit should talk to itself, its direct inputs, directly owned collaborators, and values it creates.
- Review chained calls, deep property access, layer skipping, and cross-boundary traversal.
- Optimize for lower coupling, not literal dot-count; stay pragmatic for local plain-data transformations.

### Design by Contract

- State what each public boundary expects on entry, guarantees on exit, and must preserve throughout.
- Review preconditions, postconditions, invariants, side effects, and error modes for APIs, CLIs, schemas, env vars, and module boundaries.
- Prefer executable contracts through types, assertions, schemas, and targeted tests where possible.

### Encapsulation

- Keep state with the operations that maintain it, and limit direct access to internals.
- Review whether callers can bypass validation or rely on private structure, incidental defaults, or file layout.
- Treat exported fields, functions, attrs, and options as public API surface that must stay intentionally small.

### Command-Query Separation (CQS)

- A callable should either change state or return information, but not both.
- Review query-shaped operations for hidden writes, and command-shaped operations that double as the main read path.
- Prefer explicit pairs such as `plan/apply`, `validate/fix`, `render/persist`, or `diff/write`.
- Allow documented exceptions only when atomicity, concurrency, or ergonomics clearly justify them.

### Principle of Least Astonishment (POLA)

- Make behavior match names, syntax, defaults, and local conventions.
- Review surprising defaults, hidden context, nonstandard semantics, and cross-layer drift.
- If surprising behavior is necessary, signal it explicitly in naming, comments, and docs instead of relying on tribal knowledge.
