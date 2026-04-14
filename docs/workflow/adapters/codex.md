# Codex Adapter

## Integration Surface

- agent playbook in `dotfiles/common/.codex/agents/AGENTS.md`
- agent prompts under `dotfiles/common/.codex/agents/`
- map read-only role contracts to codex subagent/task invocation
- map abstract capabilities to codex file/search/edit/shell/web tools
- enforce queue and escalation in orchestrator state machine while keeping implementation in the main thread

## Required Behavior

- maintain same handoff schema as core docs where possible, with Codex-specific routing back to the main thread for implementation
- spawn child agents only when the user explicitly requests child-agent delegation
- allow only read-only child agents with an empty `write_set`
- keep all repository edits and implementation ownership in the main Codex thread
- default reviewer and tester stages to in-thread execution in the main Codex thread
- allow reviewer and tester child agents only as bounded read-only helpers when the user explicitly requested child-agent delegation for parallel validation
- preserve reviewer-to-implementation loop and `max_review_cycles`
- apply user-selected `escalation_policy`

## Ownership Defaults

- shared packet values stay runtime-neutral
- `implementation_owner = primary-runtime`, which maps to `main-thread`
- `review_owner = primary-runtime` by default, `read-only-helper` only when the user explicitly requests child-agent delegation for parallel validation
- `test_owner = primary-runtime` by default, `read-only-helper` only when the user explicitly requests child-agent delegation for parallel validation

## Validation Paths

Codex supports two validation paths that share the same stage contracts:

1. in-thread validation
   - main thread implements
   - main thread runs reviewer logic
   - main thread runs tester logic
2. delegated read-only validation
   - main thread implements
   - read-only reviewer/tester child agents inspect or validate in parallel
   - any remediation routes back to the main-thread implementation owner

## Notes

- codex runtime differences should be adapter-only
- writable coder subagents are intentionally disabled in the Codex adapter
- shared standards memory remains in `dotfiles/common/.codex/AGENTS.md`
- shared implementation rules live in `dotfiles/common/.codex/rules/implementation-standards.md`
- shared validation-loop rules live in `dotfiles/common/.codex/rules/workflow-loop.md`
