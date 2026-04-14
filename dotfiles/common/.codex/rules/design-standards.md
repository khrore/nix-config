# Cross-Language Design Standards

Use this reference for TypeScript, Python, and general-routed tasks during planning, implementation, and review. These are design-selection rules, not formatting rules.

Rust-routed tasks continue to use `dotfiles/common/.codex/rules/rust-design-standards.md` as their primary standards source.

## Profiles

Available non-Rust `standards_profile.profile_name` values:

- `library-api`
- `service-backend`
- `ui-component`
- `automation-script`
- `configuration-module`
- `general-default`

Do not invent new non-Rust profile names. Choose the closest profile for the task and record any exceptions in `deviations_allowed`.

## Core Rules

### `single-reason-to-change`

- Keep each module, component, class, or function aligned to one cohesive reason to change.
- Split units that mix policy, I/O, formatting, persistence, and orchestration unless doing so would only add wrappers with no clarity gain.
- Reviewer should flag modules that serve unrelated actors or combine policy with infrastructure without a clear reason.

### `dry-knowledge-source`

- Keep each rule, default, enum list, parser, or operational mapping in one authoritative place.
- Deduplicate only when the abstraction stays clearer than the repetition.
- Reviewer should flag repeated domain rules, variant lists, and branching that can drift.

### `simple-solutions-first`

- Prefer the smallest structure that satisfies current requirements without speculative layers.
- Add indirection only when it improves boundaries, failure handling, or testability.
- Reviewer should flag premature plugin systems, abstraction stacks, or indirection with no current payoff.

### `explicit-contracts`

- Make inputs, outputs, invariants, and failure modes visible at the boundary.
- Use precise types, validation, and explicit error handling where invalid input or partial success matters.
- Reviewer should flag silent fallback behavior, ambiguous return shapes, and hidden invariants.

### `local-collaboration-boundaries`

- Keep modules talking to direct collaborators and stable interfaces instead of reaching deeply through nested structure.
- Prefer direct inputs over hidden globals or multi-hop lookups.
- Reviewer should flag reach-through access patterns and helpers that know too much about internal structure.

## Language Mapping

TypeScript:

- prefer interfaces, discriminated unions, and composition over deep class trees
- prefer narrow modules and hooks over components that fetch, transform, render, and persist at once
- use readonly data and explicit result or error shapes when behavior depends on boundary guarantees

Python:

- prefer focused functions, dataclasses, protocols, and composition over broad utility modules or mixin-heavy hierarchies
- separate orchestration, domain logic, and adapters when they change for different reasons
- use explicit exception or result models when callers need predictable failure handling

General:

- for shell, Nix, and configuration-heavy work, keep one file or module responsible for one concern or decision surface
- prefer explicit inputs, obvious defaults, and the least surprising wiring

General mapping:

- keep file-local details, helper state, and config assembly internals hidden behind clear module outputs

Reviewer should flag:

- direct external mutation of internal state or callers depending on private representation details

### `separate-commands-from-queries`

Intent:

- Keep reads free of side effects and make state-changing operations explicit.

Apply when:

- an API both returns information and mutates hidden state, caches, or external systems in surprising ways

Avoid when:

- the language or framework conventionally treats a specific operation as stateful and the behavior is already explicit to callers

TypeScript mapping:

- keep getters, selectors, and pure helpers free of mutation; make writes and persistence actions explicit commands

Python mapping:

- keep inspection methods and predicates side-effect free; separate update operations from queries

General mapping:

- avoid commands that also masquerade as read helpers, especially in scripts and configuration assembly

Reviewer should flag:

- queries that mutate state, hidden writes in accessors, or command/query boundaries that surprise the caller

### `least-astonishment-api`

Intent:

- Make behavior align with reasonable caller expectations instead of internal convenience.

Apply when:

- naming, defaults, return values, or edge-case handling could surprise maintainers or users

Avoid when:

- strict backward compatibility requires preserving a documented legacy behavior

TypeScript mapping:

- use predictable names, explicit nullability, and conventional prop or function semantics

Python mapping:

- use idiomatic names, stable defaults, and behavior consistent with normal Python expectations

General mapping:

- prefer conventional file names, option behavior, and module contracts that match surrounding repo patterns

Reviewer should flag:

- misleading names, surprising defaults, hidden side effects, or behavior that contradicts established repo conventions

### `semantic-types-over-primitives`

Intent:

- Use stronger types or value objects where raw primitives would allow meaningful mistakes.

Apply when:

- IDs, units, validated strings, modes, or domain-specific flags can be confused

Avoid when:

- wrappers add ceremony without increasing safety, clarity, or validation leverage

TypeScript mapping:

- use branded types, opaque wrappers, discriminated unions, or validated objects instead of interchangeable strings and numbers

Python mapping:

- use `NewType`, enums, frozen dataclasses, or value objects instead of ambiguous primitives when misuse risk is real

General mapping:

- use named constants, explicit attribute sets, or focused structures instead of unlabeled positional values

Reviewer should flag:

- repeated raw primitives in semantically distinct roles where mix-ups are plausible

### `constructor-vs-builder`

Intent:

- Use simple construction for simple objects and staged construction only when complexity justifies it.

Apply when:

- an object has many optional fields, cross-field validation, or call sites that are becoming unclear

Avoid when:

- a builder would add ceremony for a small, obvious object

TypeScript mapping:

- prefer direct constructors, factory functions, or options objects until validation or readability justifies a builder

Python mapping:

- prefer keyword arguments, classmethods, or small factories until staged configuration becomes necessary

General mapping:

- prefer direct declaration over multi-step assembly unless staged validation is required

Reviewer should flag:

- telescoping construction, unreadable initialization, or builders used for trivial data

### `scoped-resource-lifetime`

Intent:

- Tie resource setup and cleanup to scope so early returns and failures do not leak state.

Apply when:

- code manages files, locks, temp state, transactions, environment changes, or cleanup-sensitive resources

Avoid when:

- the operation is stateless and resource management is not part of the task

TypeScript mapping:

- use `try/finally`, disposables, abort handling, or scope-bound cleanup helpers

Python mapping:

- use context managers, `with`, and `try/finally` for files, locks, temporary state, and cleanup-sensitive work

General mapping:

- structure commands and module logic so cleanup is guaranteed even on failure

Reviewer should flag:

- manual cleanup that can be skipped, leaked temporary state, or cleanup logic spread across branches

### `explicit-error-model`

Intent:

- Represent expected failures explicitly and keep error behavior consistent with the boundary contract.

Apply when:

- a caller needs to handle domain failures, validation errors, external system issues, or partial success

Avoid when:

- the failure is unrecoverable programmer error and immediate failure is the clearer behavior

TypeScript mapping:

- use discriminated union results, typed errors, or clearly documented exception boundaries for expected failure modes

Python mapping:

- use explicit exception classes, result objects, or narrow error translation at boundary layers

General mapping:

- surface failure states directly instead of silently defaulting, swallowing errors, or returning ambiguous values

Reviewer should flag:

- silent fallbacks, lossy error translation, broad exception swallowing, or undocumented failure channels

### `minimize-shared-mutation`

Intent:

- Keep mutable shared state small, deliberate, and easy to reason about.

Apply when:

- state is aliased across async tasks, callbacks, modules, or long control flows

Avoid when:

- a local mutation is clearly confined and simpler than forcing immutability everywhere

TypeScript mapping:

- prefer immutable updates, `readonly` data, pure transforms, and deliberate copies over shared object mutation

Python mapping:

- avoid mutable defaults, implicit aliasing, and broad in-place mutation across layers; copy intentionally when ownership is shared

General mapping:

- keep mutation narrow and obvious, especially in scripts, generated config, and multi-step command logic

Reviewer should flag:

- accidental aliasing, wide shared mutable state, or mutation used as a workaround for poor boundary design

### `single-choice-for-variants`

Intent:

- Keep the exhaustive list of alternatives in one authoritative place.

Apply when:

- the system supports multiple modes, providers, backends, feature flags, or variant-specific branches

Avoid when:

- the list is intentionally open-ended and extension is delegated to a plugin registry

TypeScript mapping:

- centralize discriminated unions, registries, and branch dispatch so variant additions do not require hunting across files

Python mapping:

- centralize enums, registries, and dispatch tables instead of scattering exhaustive `if/elif` trees

General mapping:

- keep package choices, host alternatives, and environment modes controlled by one explicit decision point

Reviewer should flag:

- scattered exhaustive lists, repeated variant branching, or multiple modules each maintaining the same alternatives

### `self-documenting-modules`

Intent:

- Make a module’s purpose, boundary, and behavior discoverable from the module itself.

Apply when:

- naming, exports, defaults, or module layout are unclear without external explanation

Avoid when:

- extra surface area would only restate obvious local behavior

TypeScript mapping:

- use clear names, focused exports, and local helper structure that reveals the module boundary

Python mapping:

- use clear module names, obvious entry points, and succinct docstrings or type hints where the boundary would otherwise be unclear

General mapping:

- keep file names, exported attributes, and inline structure aligned with the behavior they provide

Reviewer should flag:

- ambiguous module purpose, unclear exports, or files that require external tribal knowledge to understand their role

## Advisory Guidance

These principles inform design choices but are not default reviewer gates in v1:

### `linguistic-modular-units`

- Prefer modules that correspond to real language or repo units such as files, packages, crates, or clearly named components.

### `uniform-access`

- Prefer interfaces that do not force callers to care whether a value is computed or stored, unless the distinction is semantically important.

### `persistence-closure`

- Consider dependent-data lifecycle when storing and retrieving structured state, but do not force this as a default cross-language review gate.

## Profile Defaults

### `library-api`

Default applied rules:

- `single-reason-to-change`
- `explicit-contracts`
- `encapsulated-state`
- `semantic-types-over-primitives`
- `least-astonishment-api`
- `constructor-vs-builder`
- `single-choice-for-variants`

### `service-backend`

Default applied rules:

- `single-reason-to-change`
- `composition-over-hierarchy`
- `dry-knowledge-source`
- `explicit-contracts`
- `explicit-error-model`
- `scoped-resource-lifetime`
- `minimize-shared-mutation`

### `ui-component`

Default applied rules:

- `single-reason-to-change`
- `composition-over-hierarchy`
- `simple-solutions-first`
- `encapsulated-state`
- `separate-commands-from-queries`
- `least-astonishment-api`

### `automation-script`

Default applied rules:

- `simple-solutions-first`
- `dry-knowledge-source`
- `explicit-contracts`
- `explicit-error-model`
- `scoped-resource-lifetime`
- `self-documenting-modules`

### `configuration-module`

Default applied rules:

- `single-reason-to-change`
- `dry-knowledge-source`
- `simple-solutions-first`
- `single-choice-for-variants`
- `least-astonishment-api`
- `self-documenting-modules`

### `general-default`

Default applied rules:

- `simple-solutions-first`
- `dry-knowledge-source`
- `explicit-contracts`
- `least-astonishment-api`
