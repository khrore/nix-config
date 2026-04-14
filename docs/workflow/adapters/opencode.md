# OpenCode Adapter

## Integration Surface

- agent markdown files under `dotfiles/common/.config/opencode/agents/`
- runtime config in `dotfiles/common/.config/opencode/opencode.json`
- queue enforcement via `agent.<name>.permission.task`

## Key Controls

- `workflow-orchestrator` honors `orchestrator_visibility: hidden` via `hidden: true`
- each stage can invoke only allowed next stages
- web fetch read access is globally allowed
- write/mutation behavior remains policy-gated by role and workflow state

## Notes

- keep prompts role-focused and context-driven
- keep policy semantics in shared docs, not duplicated as divergent local rules
