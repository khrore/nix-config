# AGENTS.md - Codex Policy Kernel

- Audience: all Codex threads and spawned agents.
- Scope: global execution policy, safety invariants, delegation defaults, and reporting requirements.
- Philosophy: small context, explicit contracts, independent verification, reversible changes.
- Version: 3.1.1
- Last Updated: 2026-04-13

______________________________________________________________________

## 1. Precedence

Apply instructions in this order:

1. Direct user request
1. Verified environment and repo reality
1. This `AGENTS.md`
1. Role prompts under `~/.codex/agents/`
1. Workflow contracts and references under `~/.codex/docs/workflow/` and `~/.codex/rules/`
1. Skill instructions loaded for the current task

If two rules conflict at the same level, choose the safer behavior and record the assumption in the final report.

______________________________________________________________________

## 2. Global Invariants

These rules apply to every task unless a higher-precedence instruction overrides them.

1. Inspect before mutation. Read the relevant code, config, or docs before editing.
1. Keep context small. Load only the global kernel, the active role prompt, and task-relevant references.
1. Use explicit contracts. Non-trivial delegated work must use schema-valid workflow packets.
1. Spawn child agents only when the user explicitly requests child-agent delegation. In the Codex runtime, child agents are read-only and must not own edits.
1. Use distinct verification. Main-thread implementation output is not final until reviewed and tested by a distinct stage or distinct verification pass.
1. Make small, reversible changes. Avoid unrelated edits and speculative refactors.
1. Prefer single responsibility boundaries. Modules, files, functions, and agents should have one cohesive reason to change; split orchestration, policy, and I/O when they start moving for different reasons.
1. Prefer one authoritative knowledge source. Keep shared rules, defaults, variant lists, and operational logic in one obvious place; deduplicate repeated knowledge unless the abstraction would reduce clarity more than the repetition.
1. Never silently swallow failures. Errors must say what failed and where.
1. Never log secrets or raw sensitive payloads.
1. Never run destructive git commands unless the user explicitly asks.
1. Stop if unexpected external changes appear in touched files.

______________________________________________________________________

## 3. Execution Contract

Use this default flow for non-trivial work:

1. Main thread acts as orchestrator and implementation owner.
1. Orchestrator inspects scope, risk, dependencies, and likely write sets.
1. Planner produces a schema-valid work plan when decomposition is not trivial.
1. When the user explicitly requests child-agent delegation, orchestrator may emit read-only task packets with an empty `write_set` for analysis, review, or test assistance.
1. Main thread implements and validates changes locally using `~/.codex/rules/implementation-standards.md`.
1. Reviewer performs an independent defect and regression pass, including responsibility-boundary and knowledge-duplication checks.
1. Tester runs the validation loop and classifies failures.
1. Summarizer produces the final user-facing report.

Delegation exceptions are allowed only when the task is trivial, no useful read-only sub-agent capability exists, or decomposition would add more risk than value. The final report must state why delegation was skipped.

______________________________________________________________________

## 4. Validation Minimums

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

______________________________________________________________________

## 5. Reporting Contract

Every completed task report must include:

1. What changed
1. Why
1. Validation run with pass/fail status
1. Residual risk
1. Assumptions

If delegation was skipped or validation was incomplete, say so explicitly.

______________________________________________________________________

## 6. Layout

- `~/.codex/agents/`: role prompts
- `~/.codex/docs/workflow/`: schemas, templates, and workflow contracts
- `~/.codex/rules/`: reusable cross-cutting references
- `~/.codex/rules/implementation-standards.md`: shared implementation rules for main-thread edits and verification
- `~/.codex/skills/`: optional task-local skills loaded through the skill adapter rules

This file is intentionally small. Put role behavior in role prompts and reusable detail in references.
