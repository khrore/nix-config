# Rust Design Standards

Use this reference for Rust task planning, implementation, and review. These are design-selection rules, not formatting rules.

## Profiles

Available `standards_profile.profile_name` values:

- `library-api`
- `service-backend`
- `async-io`
- `domain-model-heavy`
- `ffi-boundary`

Choose the closest profile for the task and record any exceptions in `deviations_allowed` instead of inventing a new profile.

Each applied rule should be recorded in `standards_profile.applied_rules` by rule id.

## Rules

### `borrowed-args`

Use borrowed argument types when the callee does not need ownership.

Prefer:

- `&str` over `&String`
- `&[T]` over `&Vec<T>`
- `&T` over `&Box<T>`

Do not apply when:

- the function must consume ownership
- the type is intentionally owned for task transfer, storage, or established API ergonomics

Reviewer should flag:

- public or reusable internal APIs that take owned values or over-specific borrowed wrappers without a task-specific reason

### `newtype-domain-model`

Use `newtype` wrappers when semantic confusion would allow incorrect values to be mixed or when invariants should be enforced at the type boundary.

Good fits:

- IDs
- validated strings
- units
- domain-specific numeric values

Do not apply when:

- the wrapper adds no meaningful safety or clarity
- repo conventions intentionally keep the boundary unwrapped

Reviewer should flag:

- repeated raw `String`, `Uuid`, integer, or float usage where semantic mix-ups are plausible

### `constructor-vs-builder`

Use direct constructors for simple required-field initialization. Use a builder when construction has many optional fields, staged configuration, validation, or readability issues.

Prefer constructor when:

- there are only a few required fields
- defaults are obvious
- the call site stays readable

Prefer builder when:

- optional fields are numerous
- call-site readability is degrading
- validation spans multiple fields

Reviewer should flag:

- telescoping constructors with poor readability
- unnecessary builders for trivial structs

### `raii-resource-scope`

Use RAII to tie resource cleanup or temporary state transitions to scope.

Good fits:

- locks
- transactions
- temporary configuration flips
- file and handle wrappers

Reviewer should flag:

- manual cleanup paths that are easy to bypass
- temporary state that can leak on early return

### `contain-unsafe`

Keep `unsafe` in the smallest auditable module or function set and expose a safe outer API whenever practical.

Requirements:

- state invariants next to the unsafe boundary
- keep callers from depending on undocumented assumptions
- prefer one narrow unsafe abstraction over scattered unsafe blocks

Reviewer should flag:

- unsafe invariants spread across unrelated modules
- safe callers forced to maintain hidden invariants

### `no-borrow-checker-clone`

Do not introduce `.clone()` primarily to satisfy borrow checking when the real issue is ownership or lifetime design.

Allowed exceptions:

- small, intentional value duplication with clear semantics
- clone required by an existing API boundary and justified in notes

Reviewer should flag:

- clone added only to silence ownership pressure
- clone that silently forks state or introduces avoidable allocation

### `no-deref-polymorphism`

Do not use `Deref` to emulate inheritance or method reuse between structs. Prefer composition and explicit forwarding or trait-based abstraction.

Allowed exceptions:

- smart-pointer-like wrapper semantics where deref behavior is the natural API

Reviewer should flag:

- `Deref<Target = Inner>` added to make one struct behave like another domain type

## Profile Defaults

### `library-api`

Default applied rules:

- `borrowed-args`
- `newtype-domain-model`
- `constructor-vs-builder`
- `no-borrow-checker-clone`
- `no-deref-polymorphism`

### `service-backend`

Default applied rules:

- `borrowed-args`
- `constructor-vs-builder`
- `raii-resource-scope`
- `no-borrow-checker-clone`

### `async-io`

Default applied rules:

- `borrowed-args`
- `constructor-vs-builder`
- `raii-resource-scope`
- `no-borrow-checker-clone`

Use owned types intentionally when crossing task boundaries or storing state for spawned work.

### `domain-model-heavy`

Default applied rules:

- `borrowed-args`
- `newtype-domain-model`
- `constructor-vs-builder`
- `no-borrow-checker-clone`
- `no-deref-polymorphism`

### `ffi-boundary`

Default applied rules:

- `contain-unsafe`
- `raii-resource-scope`
- `newtype-domain-model`
- `no-borrow-checker-clone`

Call out safety invariants explicitly in planning, implementation notes, and review findings.
