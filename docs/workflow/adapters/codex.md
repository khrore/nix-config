# Codex Adapter

## Integration Surface

- agent playbook in `dotfiles/common/.codex/agents/AGENTS.md`
- agent prompts under `dotfiles/common/.codex/agents/`
- map read-only role contracts to codex subagent/task invocation
- map abstract capabilities to codex file/search/edit/shell/web tools
- enforce queue and escalation in orchestrator state machine while keeping implementation in the main thread

## Required Behavior

- maintain same handoff schema as core docs where possible, with Codex-specific routing back to the main thread for implementation
- spawn child agents only on explicit user request
- allow only read-only child agents with an empty `write_set`
- keep all repository edits and implementation validation in the main Codex thread
- preserve reviewer-to-implementation loop and `max_review_cycles`
- apply user-selected `escalation_policy`

## Notes

- codex runtime differences should be adapter-only
- writable coder subagents are intentionally disabled in the Codex adapter
- shared standards memory remains in `dotfiles/common/.codex/AGENTS.md`
- shared implementation rules live in `dotfiles/common/.codex/rules/implementation-standards.md`
