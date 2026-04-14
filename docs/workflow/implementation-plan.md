# Final Implementation Plan

## Objective

Implement a portable, context-driven multiagent workflow with OpenCode as the first runtime,
while preserving adapter compatibility with Codex and Claude runtimes.

## Phase 1: Core Specification

1. Publish runtime-neutral docs:
   - `core-spec.md`
   - `handoff-schema.md`
   - `policy.md`
2. Freeze required fields and stage responsibilities.

Exit criteria:

- all stages have deterministic output contracts
- escalation and reviewer loop semantics are fully defined

## Phase 2: Adapter Definitions

1. Publish adapter tables and mappings in `adapter-mapping.md`.
2. Keep policy in core docs, not in adapter-specific prompts.

Exit criteria:

- every abstract capability maps to OpenCode, Codex, and Claude runtime concepts

## Phase 3: OpenCode Runtime Integration

1. Create agent files in `dotfiles/common/.config/opencode/agents/`.
2. Add queue enforcement with `permission.task` in `opencode.json`.
3. Add language-specific coder/reviewer agents including TypeScript.
4. Set `workflow-orchestrator` hidden by default.

Exit criteria:

- queue is enforceable via config
- reviewer can route back to coder for fixes
- TypeScript coder/reviewer are available

## Phase 4: Governance and Documentation

1. Update `README.md` with workflow onboarding.
2. Update root `AGENTS.md` with workflow governance summary.

Exit criteria:

- humans can create workflows with escalation settings
- policy behavior is discoverable from repository docs

## Phase 5: Validation

Smoke scenarios:

1. docs-only low-risk request
2. TypeScript feature request
3. reviewer rejection and loop-back remediation
4. risky human decision triggering escalation

Validation checks:

- route correctness
- payload completeness
- max review cycle handling
- policy-compliant escalation behavior

## Final Acceptance Criteria

- user-defined `escalation_policy` at workflow creation is supported
- `orchestrator_visibility: hidden` default is enforced
- external read-only requests are allowed
- reviewer-to-implementation-owner remediation loop is active with max cycle limit
- workflow is not coupled to OpenCode internals due to adapter-based design
