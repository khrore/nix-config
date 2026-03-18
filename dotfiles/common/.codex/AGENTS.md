# AGENTS.md - Software Development Standards v2

- Audience: All coding agents and language models (model-agnostic memory file).
- Scope: Backend-focused standards for software delivery across multiple languages.
- Philosophy: Make illegal states unrepresentable where practical. Type safety and validation before velocity.
- Last Updated: 2026-03-17

______________________________________________________________________

## 1. Purpose, Scope, Audience

This document defines the canonical engineering and execution policy for software development tasks.

- Purpose: Improve correctness, safety, and maintainability of delivered changes.
- Scope: Design, implementation, validation, and review behavior for agents and engineers.
- Audience: Humans and agents collaborating on code changes.

This file is the single source of truth for standards in this repository context.

______________________________________________________________________

## 2. How to Read This Document (Normative Keywords and Precedence)

### 2.1 Normative Keywords

- MUST / MUST NOT: mandatory requirement.
- SHOULD / SHOULD NOT: strong default; deviations require explicit rationale.
- MAY: optional.

### 2.2 Policy Precedence Interface

Policy precedence is:

`Document Precedence > Section Precedence > Rule Severity`

Interpretation:

1. Document Precedence: This file overrides ad-hoc guidance unless explicitly superseded by user instruction.
2. Section Precedence: Core sections apply to all languages; language profiles add stricter constraints.
3. Rule Severity: `MUST` overrides `SHOULD`, which overrides `MAY`.

Conflict resolution rules:

1. If Core and profile conflict, apply the stricter rule.
2. If two rules of same severity conflict, choose the safer behavior and log assumption in the report.
3. If ambiguity remains, ask before mutating high-risk areas.

______________________________________________________________________

## 3. Global Engineering Priorities (Single Canonical Ordering)

### 3.1 Design Priority

1. Maintainability
2. Simplicity
3. Extensibility

### 3.2 Change Decision Priority

1. Correctness
2. Safety
3. Clarity
4. Speed

Compilation and type checks provide baseline confidence; runtime behavior is validated by tests and operational checks.

______________________________________________________________________

## 4. Core Rules (Language-Agnostic)

### 4.1 Stable Rule Schema

All normative rules use this schema:

`Rule ID | Level | Rule Text | Enforcement | Evidence | Exception Path`

### 4.2 Core Rule Catalog

| Rule ID | Level | Rule Text | Enforcement | Evidence | Exception Path |
|---|---|---|---|---|---|
| CORE-01 | MUST | Represent domain concepts with domain types; avoid primitive obsession for critical concepts. | Review + type checks | API signatures and domain type definitions in diff | Section 14 exception request |
| CORE-02 | MUST | Prefer explicit state models (enum/value object/state machine) over boolean flags for domain behavior. | Review + tests | Type definitions and branch coverage in tests | Section 14 exception request |
| CORE-03 | MUST | Make invalid states unrepresentable where practical. | Review + tests | Constructors/validators and failing tests for invalid input | Section 14 exception request |
| CORE-04 | MUST NOT | Silently swallow errors. | Lint/review/tests | Error propagation in code path, no silent fallback in diff | Section 14 exception request |
| CORE-05 | MUST | Error messages identify WHAT failed and WHERE. | Review + tests | Error type/message assertions | Section 14 exception request |
| CORE-06 | MUST NOT | Log secrets or raw sensitive payloads. | Review + logging tests | Redaction wrappers and sanitized log output | Section 14 exception request |
| CORE-07 | MUST NOT | Run destructive git operations unless explicitly requested. | Process control | Command history + user instruction reference | Not applicable |
| CORE-08 | MUST | Stop and escalate if unexpected external changes appear in touched files. | Process control | Explicit stop note in report | Not applicable |
| CORE-09 | MUST | Depend on abstractions at boundaries and multi-implementation seams; avoid speculative abstractions before Rule of Three. | Review | Boundary interfaces and usage count rationale | Section 14 exception request |
| CORE-10 | MUST | Reports include: What changed, Why, Validation run, Residual risk, Assumptions. | Process control | Final report sections present | Not applicable |
| CORE-11 | MUST | Exhaust local self-validation and remediation loops before escalating routine scoped work. | Process + command run | Recorded formatter/linter/type/build/test loop and result classification | Section 14 exception request |

### 4.3 Enforcement Matrix (Top Rules)

| Rule | Enforcement | Evidence |
|---|---|---|
| No silent error swallowing | Lint/review/tests | Propagated errors in diff; explicit assertions on error paths |
| No unsafe secret logging | Review + logging tests | Redacted output and sanitized error handling |
| No runtime unwrap/expect misuse (Rust) | Clippy + review | `cargo clippy` output and code scan |
| No broad except swallowing (Python) | Ruff + review | `ruff check` output and exception handling diff |
| Validation execution by risk tier | Process + command run | Recorded commands/results per tier |
| Self-validation before escalation | Process + command run | Formatter/linter/type/build/test loop and failure classification in report |
| Stop on unexpected external changes | Process control | Explicit stop/escalation note in report |

______________________________________________________________________

## 5. Execution Protocol (Analyze-First, Risk-Tiered)

### 5.1 Analyze-First Sequence

For every non-trivial request:

1. Understand
- Restate goal in concrete terms.
- List assumptions and unknowns.

2. Inspect
- Read code/config/tests before proposing edits.
- Prefer read-only exploration first.

3. Plan
- Define files to touch, behavior changes, validation, and risks.

4. Gate
- Apply risk-tier approval rules before writes, favoring self-validation over routine human confirmation for scoped work.

5. Implement
- Make minimal, reversible changes.
- Keep style and architecture consistent with existing conventions.

6. Validate
- Run smallest useful checks first, then broader checks per risk.

7. Report
- Include required reporting contract fields.

### 5.2 Risk Tier Interface

`Low | Medium | High`

| Tier | Typical Changes | Minimum Validation | Approval Gate |
|---|---|---|---|
| Low | Local refactor, docs, non-behavioral cleanup | Targeted checks or tests for touched area | No extra gate when user explicitly requested implementation |
| Medium | Behavioral change in existing module, non-breaking API internals | Profile default checks + targeted tests + remediation loop when checks fail | No extra gate when scope is explicit, ownership is bounded, and validation passes; confirm only when unresolved assumptions materially affect behavior |
| High | Persistence, concurrency model, security paths, migrations, public interfaces | Full profile checks + targeted integration tests + rollback notes | Explicit user confirmation required before mutating |

### 5.3 Gate Rules

- MUST gate before writing high-risk changes.
- SHOULD gate medium-risk changes only when assumptions remain unresolved after reasonable self-validation.
- MAY proceed immediately for low-risk changes after inspection when implementation is explicitly requested.
- MUST prefer the safest locally verifiable assumption and record it when medium-risk work can proceed without expanding scope.

______________________________________________________________________

## 6. Agent Governance (Autonomy Budget, Automatic Delegation, Stop Conditions, Reporting Contract)

### 6.1 Autonomy Budget

Without re-confirmation, an agent SHOULD initially aim to stay within all of:

1. Up to 3 files changed.
2. Up to 200 net lines changed.
3. No public API contract changes.

If any threshold is exceeded, the agent MAY continue without confirmation only when all of the following hold:

1. Scope is still coherent and explicitly bounded.
2. No newly discovered public API, migration, or security-sensitive impact appears.
3. The agent can complete meaningful self-validation for the expanded change.
4. The final report explicitly records the scope expansion and why it was needed.

If those conditions do not hold, the agent MUST pause and request confirmation.

### 6.2 Automatic Delegation Policy

For non-trivial implementation work, the main Codex thread MUST use a multiagent execution pattern by default rather than keeping all work local.

Default execution model:

1. Main thread inspects scope, risk, and likely write set.
2. Main thread delegates at least one concrete subtask to a worker-style sub-agent when the task includes code changes, validation work, review work, or other bounded parallelizable work.
3. Main thread reserves local work for integration, conflict resolution, risk decisions, and final reporting.
4. Main thread MUST create a dedicated self-verification loop through either:
- a verifier/tester/reviewer sub-agent, or
- a separate delegated validation pass owned by a sub-agent distinct from the primary implementation agent.
5. The verification sub-agent MUST run or explicitly assess, when applicable:
- formatter check
- linter check
- type or LSP-equivalent check
- build/compile check
- targeted tests
- broader tests when risk or scope requires
6. The main thread MUST review verifier results and either remediate failures locally or delegate remediation before finalizing.

Delegation exceptions:

1. The task is trivial and can be completed safely with no meaningful benefit from delegation.
2. The environment exposes no usable sub-agent capability.
3. The task is so tightly coupled that delegation would create more coordination risk than execution value.

If an exception is used, the final report MUST state why automatic delegation was skipped.

### 6.3 Stop Conditions

Agent MUST stop and ask before continuing when any of the following occurs:

1. Unexpected external changes appear in touched files.
2. Planned change affects public interfaces not in approved scope.
3. Persistence schema or migration impact is discovered unexpectedly.
4. Security-critical behavior must change without explicit requirement.
5. Validation remains materially incomplete after exhausting reasonable local checks and remediation loops.

Agent SHOULD continue without asking when validation failures are routine, scoped, and remediable through local iteration.

### 6.4 Reporting Contract

Every completed task report MUST include:

1. What changed
2. Why
3. Validation run (commands and pass/fail)
4. Residual risk
5. Assumptions

______________________________________________________________________

## 7. Error Handling and Secrets (Language-Agnostic Core)

### 7.1 Error Boundaries

- MUST use typed/domain-specific error boundaries.
- MUST include context at each propagation boundary.
- MUST NOT replace failures with silent defaults.

### 7.2 Failure Policy

- MUST fail fast at startup/bootstrap when required configuration is invalid or missing.
- SHOULD include actionable failure context for operators.
- MUST keep runtime business logic error handling explicit and typed.

### 7.3 Sensitive Data Policy

- MUST redact secrets in `Debug`, logs, and user-facing errors.
- MUST treat tokens, passwords, API keys, and connection strings as secrets.
- MUST sanitize third-party SDK errors before logging.

______________________________________________________________________

## 8. Concurrency and Resource Lifecycle (Language-Agnostic Core)

### 8.1 Concurrency Defaults

- SHOULD prefer message passing/channels over shared mutable state.
- MUST avoid holding non-async-safe locks across suspension points.
- MUST account for cancellation behavior in concurrent control flows.

### 8.2 Cancel Safety

- MUST verify that canceled branches do not corrupt state.
- SHOULD isolate non-cancel-safe operations in dedicated tasks/threads with explicit join handling.

### 8.3 Resource Lifecycle

- MUST make acquisition and release explicit and scope-bound.
- SHOULD use RAII/context managers and deterministic cleanup patterns.
- MUST provide explicit close/shutdown path for resources requiring ordered teardown.

______________________________________________________________________

## 9. Testing and Validation Strategy (Language-Agnostic Core)

### 9.1 Validation Principles

- MUST validate behavior changes, not only compile/type success.
- MUST test error paths with specific expected outcomes.
- SHOULD test boundaries and failure modes for medium/high-risk changes.
- MUST run local self-validation in a repair loop before escalating routine scoped failures.

### 9.1.1 Self-Validation Loop

For routine scoped implementation work, agents SHOULD iterate through:

1. formatter check
2. linter check
3. type or LSP-equivalent check when available
4. compile/build check when applicable
5. targeted tests for changed behavior
6. broader checks only when risk or scope requires

Loop policy:

- MUST classify failures as introduced, pre-existing, environment/tooling, or scope-expanding.
- MUST self-fix introduced failures that can be resolved within the approved scope.
- SHOULD repeat the loop until checks pass or repeated unchanged failures indicate escalation is necessary.
- MUST report skipped or blocked checks with confidence impact.

### 9.2 Validation by Risk Tier

1. Low: targeted tests and static checks in touched area.
2. Medium: full profile static checks plus targeted tests.
3. High: full profile checks, targeted integration tests, and rollback/fallback notes.

### 9.3 If Validation Is Blocked

- MUST report exactly what was skipped and why.
- MUST state confidence impact and residual risk.

______________________________________________________________________

## 10. Rust Profile

### 10.1 Domain Modeling

- MUST use newtypes for critical domain primitives (IDs, money, URL-like values, secret wrappers).
- MUST use enums over booleans for domain state and mode selection.
- SHOULD encode invariants in constructors/builders so valid types imply valid values.

### 10.2 Errors

- MUST use `thiserror` for library/module error enums.
- MAY use `anyhow` only at top-level binary orchestration boundaries.
- MUST include context on propagation boundaries.

### 10.3 unwrap/expect Policy

- MUST NOT use `.unwrap()` in production/runtime business logic.
- MUST NOT use `.expect()` in runtime business logic.
- Tests and examples MAY use `.unwrap()` / `.expect()`.

### 10.4 Async and Concurrency

- MUST handle both layers from spawned tasks (`JoinError` and inner result).
- MUST avoid holding `MutexGuard` across `.await` unless using an async-aware lock with deliberate design.
- SHOULD prefer channels over shared mutable state.
- MUST reason about cancel safety in `select!` and timeout paths.

### 10.5 Resource Lifecycle

- SHOULD use RAII for deterministic cleanup.
- MUST remember `Drop` is not async; provide explicit async `close()` when async cleanup is required.

### 10.6 Default Validation Commands

Run in this order when applicable:

1. `cargo fmt`
2. `cargo clippy --all-targets --locked -- -D warnings`
3. Targeted tests for changed areas
4. Broader tests for medium/high-risk changes

______________________________________________________________________

## 11. Python Profile

### 11.1 Domain Modeling

- SHOULD use `typing.NewType` for lightweight domain identity types.
- SHOULD use validated value objects (for example frozen dataclasses or Pydantic models) for constrained domain primitives.
- MUST use `Enum` over boolean flags for domain states and modes.

### 11.2 Exceptions and Error Propagation

- MUST define domain exception hierarchies for business failures.
- MUST NOT use broad `except Exception` to swallow failures.
- If broad catch is unavoidable at process boundary, MUST add context and re-raise or convert explicitly.
- MUST include error context that identifies operation and boundary.

### 11.3 Resource Lifecycle

- MUST use context managers (`with`) for closeable resources.
- MUST provide explicit async shutdown for async resources (for example `async with` or explicit `aclose()`/`close()`).
- SHOULD avoid hidden global state for connection/resource objects.

### 11.4 Async Guidance

- MUST handle task exceptions deterministically.
- MUST define timeout behavior for external calls.
- SHOULD propagate cancellation intentionally rather than masking `CancelledError`.

### 11.5 Default Validation Commands

Run in this order when applicable:

1. `ruff check .`
2. `ruff format --check .`
3. `mypy .`
4. `pytest -q`

If a tool is unavailable, report what was skipped and the resulting risk.

______________________________________________________________________

## 12. Anti-Patterns and Approved Alternatives

| Anti-Pattern | Approved Alternative |
|---|---|
| Stringly typed domain values | Newtype/value object with validation |
| Boolean blindness in function parameters | Enum or explicit strategy type |
| Primitive obsession for money/time/identity | Domain type with constructor validation |
| Silent fallback on failure (`or default`) | Typed error propagation with context |
| God object or multi-responsibility service | Split into focused modules/services |
| Premature abstraction on first use | Rule of Three; abstract at boundary reuse point |
| Nested optional/result complexity | Explicit result enum or small state model |
| Clone/copy used to bypass ownership/design issues | Restructure ownership/lifetime boundaries |
| Broad `except` masking root causes | Narrow exception handling with explicit re-raise |
| Secret leakage in logs/errors | Redacting wrappers and sanitized logging |

______________________________________________________________________

## 13. Review Checklist

### 13.1 Cross-Language Checklist

- Type safety: domain modeling and invalid-state prevention are appropriate.
- Errors: no silent swallowing, context present, boundaries explicit.
- Secrets: redaction and sanitization are enforced.
- Concurrency: cancel safety and lifecycle handling are addressed.
- Validation: checks match risk tier and changed behavior.
- Scope control: no unrelated edits.

### 13.2 Rust-Specific Checklist

- Newtypes/enums used for domain concepts.
- No runtime `.unwrap()` / `.expect()`.
- `JoinError` and inner task failures are handled.
- Async cleanup strategy is explicit where needed.

### 13.3 Python-Specific Checklist

- Domain exceptions are structured and specific.
- No broad catch that swallows failure.
- Context managers or explicit close paths exist.
- Async cancellation and timeout behavior are explicit.

______________________________________________________________________

## 14. Exceptions and Change Management

### 14.1 Exception Request Format

Any temporary policy exception MUST include:

1. Rule ID
2. Reason
3. Scope (files/modules)
4. Risk and mitigation
5. Expiry date
6. Approver

### 14.2 Exception Rules

- Exceptions MUST be time-bounded.
- Exceptions SHOULD be as narrow as possible.
- Expired exceptions MUST be removed or renewed explicitly.

### 14.3 Policy Change Workflow

For policy updates:

1. Propose change with rationale and concrete examples.
2. Identify impacted sections and rule IDs.
3. Define migration guidance for existing workflows.
4. Record version and changelog note in Section 15.

______________________________________________________________________

## 15. Versioning and Changelog Notes

### 15.1 Versioning Policy

This document uses semantic-style policy versioning:

- MAJOR: breaking policy changes or precedence changes.
- MINOR: additive rules or new language profiles.
- PATCH: clarifications, wording, and non-semantic cleanup.

### 15.2 Current Version Notes

- Version: 2.1.1
- Date: 2026-03-18
- Summary:
  - Reorganized into language-agnostic core + Rust + Python profiles.
  - Resolved priority and `.expect()` policy conflicts.
  - Added explicit risk-tier execution model and approval gates.
  - Added rule schema and enforcement matrix with evidence expectations.
  - Added autonomy budget, stop conditions, and reporting contract.
  - Relaxed routine autonomy limits for scoped, self-validated work.
  - Shifted medium-risk execution toward validate-first autonomy instead of default human confirmation.
  - Added explicit self-validation loop requirements before escalation.
  - Added automatic multiagent delegation and distinct verification sub-agent requirements for non-trivial implementation work.

### 15.3 Changelog Entry Template

Use this template for future updates:

- Version:
- Date:
- Changed Sections:
- Reason:
- Migration Notes:

______________________________________________________________________

## 16. Codex Multiagent Layout

This file remains the shared standards memory for all Codex workflow agents under this directory.

Workflow coordination is split into dedicated files:

- `./agents/AGENTS.md`: lightweight multiagent playbook for handoff quality and routing hygiene
- `./agents/main-thread-orchestration.md`: automatic queue control, escalation handling, and reviewer loop routing by the main Codex thread
- `./agents/*.md`: stage-specific prompts for analyzer, researcher, planner, coder, reviewer, tester, technical-writer, and summarizer roles

Workflow policy, schema, and adapter contracts remain canonical in `docs/workflow/`.
