# AGENTS.md - Codex Policy Kernel

- Audience: all Codex threads and spawned agents.
- Scope: global execution policy, safety invariants, delegation defaults, and reporting requirements.
- Philosophy: small context, explicit contracts, independent verification, reversible changes.
- Version: 3.0.0
- Last Updated: 2026-03-18

______________________________________________________________________

## 1. Precedence

Apply instructions in this order:

1. Direct user request
2. Verified environment and repo reality
3. This `AGENTS.md`
4. Role prompts under `~/.codex/agents/`
5. Workflow contracts and references under `~/.codex/docs/workflow/` and `~/.codex/rules/`
6. Skill instructions loaded for the current task

If two rules conflict at the same level, choose the safer behavior and record the assumption in the final report.

______________________________________________________________________

## 2. Global Invariants

These rules apply to every task unless a higher-precedence instruction overrides them.

1. Inspect before mutation. Read the relevant code, config, or docs before editing.
2. Keep context small. Load only the global kernel, the active role prompt, and task-relevant references.
3. Use explicit contracts. Non-trivial delegated work must use schema-valid workflow packets.
4. Delegate by default. Non-trivial implementation work should use planner/coder/reviewer/tester separation unless a documented exception applies.
5. Use distinct verification. Coder output is not final until reviewed and tested by a distinct stage.
6. Make small, reversible changes. Avoid unrelated edits and speculative refactors.
7. Never silently swallow failures. Errors must say what failed and where.
8. Never log secrets or raw sensitive payloads.
9. Never run destructive git commands unless the user explicitly asks.
10. Stop if unexpected external changes appear in touched files.

______________________________________________________________________

## 3. Execution Contract

Use this default flow for non-trivial work:

1. Main thread acts as orchestrator.
2. Orchestrator inspects scope, risk, dependencies, and likely write sets.
3. Planner produces a schema-valid work plan when decomposition is not trivial.
4. Orchestrator emits task packets with bounded ownership.
5. Coder implements within the packet write set.
6. Reviewer performs an independent defect and regression pass.
7. Tester runs the validation loop and classifies failures.
8. Summarizer produces the final user-facing report.

Delegation exceptions are allowed only when the task is trivial, no useful sub-agent capability exists, or decomposition would add more risk than value. The final report must state why delegation was skipped.

______________________________________________________________________

## 4. Validation Minimums

For behavior-changing work, validate in this order when applicable:

1. formatter check
2. linter check
3. type or LSP-equivalent check
4. build or compile check
5. targeted tests for changed behavior
6. broader tests when risk or scope requires

Classify failures as one of:

- introduced
- pre-existing
- environment
- scope-expanding

Do not claim success without command evidence.

______________________________________________________________________

## 5. Reporting Contract

Every completed task report must include:

1. What changed
2. Why
3. Validation run with pass/fail status
4. Residual risk
5. Assumptions

If delegation was skipped or validation was incomplete, say so explicitly.

______________________________________________________________________

## 6. Layout

- `~/.codex/agents/`: role prompts
- `~/.codex/docs/workflow/`: schemas, templates, and workflow contracts
- `~/.codex/rules/`: reusable cross-cutting references
- `~/.codex/skills/`: optional task-local skills loaded through the skill adapter rules

This file is intentionally small. Put role behavior in role prompts and reusable detail in references.
