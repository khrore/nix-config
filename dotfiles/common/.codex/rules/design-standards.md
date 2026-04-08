# Cross-Language Design Standards

Use this reference for TypeScript, Python, and general-routed tasks during planning, implementation, and review. These are design-selection rules, not formatting rules.

Rust-routed tasks continue to use `dotfiles/common/.codex/rules/rust-design-standards.md` as their primary standards source. This file translates the same design intent into cross-language guidance without forcing Rust syntax or object-oriented structure onto other languages.

## Profiles

Available non-Rust `standards_profile.profile_name` values:

- `library-api`
- `service-backend`
- `ui-component`
- `automation-script`
- `configuration-module`
- `general-default`

Do not invent new non-Rust profile names. Choose the closest profile for the task and record any exceptions in `deviations_allowed`.

Each applied rule should be recorded in `standards_profile.applied_rules` by rule id.

## Rust-to-Cross-Language Translation

Apply Rust design ideas by intent:

- ownership and borrowing -> minimize aliasing and shared mutation; prefer `readonly`, pure helpers, deliberate copies, and narrow mutation scope
- newtypes -> prefer branded or opaque types in TypeScript and `NewType`, value objects, or small dataclasses in Python when semantics matter
- traits over inheritance -> prefer interfaces and discriminated unions in TypeScript, or `Protocol` and narrow ABCs in Python
- RAII -> use `try/finally`, `using`, or disposables in TypeScript when available; use context managers in Python
- `Result` and explicit error models -> use discriminated unions for expected failures in TypeScript and explicit exception taxonomies or result objects in Python
- builders -> use only when staged validation or many optional fields justify them; otherwise prefer options objects in TypeScript and keyword arguments in Python

## Rules

### `single-reason-to-change`

Intent:

- Keep each module, component, class, or function aligned to one actor or one cohesive reason to change.

Apply when:

- a unit mixes policy, I/O, formatting, persistence, and orchestration responsibilities
- a change request would otherwise force unrelated edits into the same unit

Avoid when:

- splitting would create wrappers with no meaningful boundary or clarity gain

TypeScript mapping:

- split controllers, services, data mappers, and presenters instead of building multipurpose classes
- prefer narrow modules and hooks over components that fetch, transform, render, and persist at once

Python mapping:

- separate orchestration, domain logic, and adapters instead of large utility modules or god classes
- prefer focused functions or small dataclasses over stateful managers with mixed concerns

General mapping:

- for Nix, shell, and config tasks, keep one file or module responsible for one concern or decision surface

Reviewer should flag:

- units that serve multiple unrelated actors or combine policy with infrastructure without a clear reason

### `composition-over-hierarchy`

Intent:

- Reuse behavior by wiring smaller parts together instead of depending on deep inheritance trees or implicit reuse.

Apply when:

- behavior varies by strategy, policy, adapter, or mode
- subclassing would leak assumptions or require fragile overrides

Avoid when:

- the language or framework already provides a narrow, conventional extension point that is simpler than composition

TypeScript mapping:

- prefer interfaces, discriminated unions, injected collaborators, and component composition over inheritance-heavy class trees

Python mapping:

- prefer delegation, protocols, callables, and composition over subclass pyramids and mixin stacks

General mapping:

- compose scripts, modules, and config fragments through explicit inputs and helpers instead of coupling behavior through hidden inheritance analogs

Reviewer should flag:

- inheritance or reuse schemes that make behavior implicit, surprising, or hard to swap

### `dry-knowledge-source`

Intent:

- Keep each piece of business or operational knowledge in one authoritative place.

Apply when:

- validation, defaults, enum alternatives, parsing rules, or command wiring are duplicated

Avoid when:

- deduplication would create an abstraction that is harder to understand than the repeated code

TypeScript mapping:

- centralize schemas, discriminated union members, parsing helpers, and shared domain logic

Python mapping:

- centralize validators, constants, normalization logic, and error messages that encode domain rules

General mapping:

- keep host lists, feature toggles, package selections, and environment mappings in one obvious source

Reviewer should flag:

- duplicated domain rules, repeated variant lists, or copy-pasted branching that can drift

### `simple-solutions-first`

Intent:

- Prefer the simplest solution that satisfies the current requirements and preserves room for later extension.

Apply when:

- multiple designs are possible and one introduces speculative layers, abstractions, or indirection

Avoid when:

- a slightly richer abstraction is necessary to make failure handling, testing, or boundaries explicit

TypeScript mapping:

- prefer plain functions, objects, and simple component boundaries before adding factories, decorators, or class hierarchies

Python mapping:

- prefer straightforward functions, modules, and dataclasses before frameworks, metaclasses, or dynamic indirection

General mapping:

- choose the smallest structure that keeps behavior explicit and maintainable

Reviewer should flag:

- speculative abstractions, premature plugin systems, or indirection with no current payoff

### `local-collaboration-boundaries`

Intent:

- Keep modules talking to direct collaborators and stable interfaces rather than reaching deeply through object graphs or nested structures.

Apply when:

- a unit depends on chains of internal structure or hidden transit paths to do its work

Avoid when:

- flattening access would only add wrappers without reducing coupling

TypeScript mapping:

- pass in the data or collaborator actually needed instead of chaining through nested services or props

Python mapping:

- avoid long attribute access chains and broad reach-through into nested objects when a narrower boundary would suffice

General mapping:

- prefer direct inputs over hidden global reads or multi-hop lookups through unrelated layers

Reviewer should flag:

- deep reach-through such as train-wreck calls, chained property access into internals, or helpers that know too much about nested structure

### `explicit-contracts`

Intent:

- Make preconditions, postconditions, invariants, and failure modes visible at the boundary.

Apply when:

- invalid input, partial success, or invariants could otherwise be inferred only from implementation details

Avoid when:

- the boundary is purely private and additional ceremony would duplicate already obvious local code

TypeScript mapping:

- use precise types, schema validation, discriminated unions, assertions, and documented return contracts

Python mapping:

- use type hints, validation, dataclass invariants, explicit exceptions, and narrow public method contracts

General mapping:

- define expected inputs, outputs, invariants, and side effects in the module or command surface itself

Reviewer should flag:

- ambiguous return shapes, silent fallback behavior, missing validation at boundaries, or hidden invariants

### `encapsulated-state`

Intent:

- Keep mutable state and implementation details behind a small, intentional API.

Apply when:

- callers can directly mutate internal structures or depend on representation details

Avoid when:

- the data is intentionally a plain transport object with no behavioral invariants

TypeScript mapping:

- expose readonly views, narrow update methods, and helper functions instead of leaking mutable internals

Python mapping:

- keep internal state private by convention, expose narrow methods or properties, and avoid letting callers mutate internal containers directly

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
