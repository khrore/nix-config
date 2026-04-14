# Multiagent Workflow Specification

## Version

- Version: 1.0.0
- Status: implementation-ready
- Scope: portable workflow for OpenCode, Codex, and Claude-style runtimes

## Goal

Use a context-driven agent workflow with explicit handoff contracts, controlled escalation,
language-aware coding/review, and a deterministic reviewer-to-implementation remediation loop.

## Stage Queue

1. analyzer
2. researcher
3. planner
4. coder (language-specific preferred)
5. reviewer (language-specific preferred)
6. tester
7. technical-writer
8. summarizer

## Runtime Ownership Notes

- The abstract workflow queue remains runtime-neutral.
- Runtime adapters may map abstract `coder`, `reviewer`, and `tester` stages onto different execution models while preserving the same stage contracts.
- In the Codex adapter, `coder` maps to `main-thread-implementation` and review/test default to in-thread execution by the main Codex thread.
- In the Codex adapter, reviewer and tester child agents are optional read-only helpers and may be used only when the user explicitly requests child-agent delegation for parallel validation.

## Language Routing

Preferred pairs:

- python-coder -> python-reviewer
- rust-coder -> rust-reviewer
- vue-coder -> vue-reviewer
- typescript-coder -> typescript-reviewer

Fallback:

- general-coder -> general-reviewer

For tasks routed to `rust-coder`, `typescript-coder`, `python-coder`, or `general-coder`, the planner binds a `standards_profile` into the handoff packet and the selected coder/reviewer path must consume it. In v1, `standards_profile` is mandatory for those routes.

For tasks routed to `rust-coder`, the researcher and planner should also bind crate/module topology context so implementation does not guess at crate ownership, module declarations, or manifest changes.

## Human Readable Scheme

```text
[User Creates Workflow]
        |
        v
[Workflow Settings]
- escalation_policy: strict | balanced | relaxed
- max_review_cycles: N (default 3)
- orchestrator_visibility: hidden
        |
        v
[workflow-orchestrator]
        |
        v
[Analyzer] -> [Researcher] -> [Planner]
                               |
                               v
                     [Language Selection]
        / python / rust / vue / typescript / general \
                               |
                               v
                            [Coder]
                               |
                               v
                            [Reviewer]
              +----------------+----------------+
              |                                 |
      approved|                         changes_required
              v                                 |
           [Tester] <---------------------------+
              |                     (loop_count + 1 with fix instructions)
              v
      [Technical Writer]
              |
              v
         [Summarizer]
              |
              v
             End
```

Escalation side path from any stage:

```text
Risk or wrong decision detected
        |
        v
Escalation packet
        |
        v
Orchestrator asks human and resumes with updated context
```

## Workflow Initialization

User sets these fields when starting workflow:

- `escalation_policy`: `strict | balanced | relaxed`
- `max_review_cycles`: integer >= 1, default `3`
- `orchestrator_visibility`: default hidden

## Escalation Behavior

Policy modes:

- `strict`: block on medium and high risks.
- `balanced`: stage-dependent block for medium, always block for high.
- `relaxed`: block only on critical/high-impact concerns.

Balanced stage-specific behavior for medium risk:

- blocking: planner, reviewer, tester
- non-blocking ask: analyzer, researcher, technical-writer, summarizer

## Reviewer Rework Loop

If reviewer is not satisfied:

1. reviewer sets `review_outcome: changes_required`
2. reviewer provides `fix_instructions[]`
3. orchestrator routes back to the same implementation owner
4. loop increments `review_cycle_count`
5. if `review_cycle_count > max_review_cycles`, escalate to human

## Skip Policy

Adaptive by risk tier:

- low risk may skip tester for docs-only or non-behavioral changes with `skip_reason`
- technical-writer may no-op when no docs impact exists
- high risk must not skip reviewer or tester

Summarizer always reports skipped stages and reasons.

## Portable Rules

- keep workflow logic platform-agnostic
- keep role contracts platform-agnostic
- enforce policy with adapter-specific permissions
- keep handoff payload stable across runtimes
- keep language standards in shared references and packet fields, not runtime-only prompt drift
- require explicit ownership for implementation, review, and testing on non-trivial implementation work

## Planner Ownership Assignment

For every non-trivial implementation task, planner output must assign ownership for:

- `implementation_owner`
- `review_owner`
- `test_owner`

Use runtime-neutral ownership values in the shared packet:

- `primary-runtime`
- `delegated-agent`
- `read-only-helper`

Adapter defaults may narrow the allowed values and map them to runtime-native concepts.

For the Codex adapter:

- `implementation_owner` must be `primary-runtime`
- `review_owner` defaults to `primary-runtime`
- `test_owner` defaults to `primary-runtime`
- `review_owner` or `test_owner` may be `read-only-helper` only when the user explicitly requested child-agent delegation for parallel validation
- the Codex runtime maps `primary-runtime` to `main-thread` and `read-only-helper` to `read-only-child`

## Design Standards Flow

For routed work that uses a `standards_profile`:

1. researcher identifies applicable design rules, repo-local overrides, and conflicts with the shared standards reference for the route
2. planner selects one `standards_profile.profile_name` and records `applied_rules`
3. coder implements against that profile and reports `standards_decisions`
4. reviewer evaluates correctness and design choices against the same profile

In v1, `standards_profile` is required for:

- `rust-coder`
- `typescript-coder`
- `python-coder`
- `general-coder`

For TypeScript-, Python-, and general-routed work, use `dotfiles/common/.codex/rules/design-standards.md` as the shared standards source.

Default non-Rust profile names:

- `library-api`
- `service-backend`
- `ui-component`
- `automation-script`
- `configuration-module`
- `general-default`

Do not invent ad hoc non-Rust profile names. Record exceptions in `deviations_allowed`.

## Rust Standards Supplement

Rust-routed work continues to use `dotfiles/common/.codex/rules/rust-design-standards.md`.

Rust-routed handoffs should also carry `module_topology_notes` when the task might touch file placement, `mod` declarations, public API surfaces, crate roots, or `Cargo.toml`.

Default Rust profile names:

- `library-api`
- `service-backend`
- `async-io`
- `domain-model-heavy`
- `ffi-boundary`
