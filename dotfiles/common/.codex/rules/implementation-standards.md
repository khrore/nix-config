# Implementation Standards

Use this file for any main-thread implementation work in the Codex runtime.

## Scope

- The main Codex thread owns all repository edits.
- Read-only child agents may inspect, review, or propose changes, but they must not edit files.
- Apply the active task brief `standards_profile` when one is bound.

## Implementation Defaults

- Keep changes minimal, safe, reversible, and inside the approved scope.
- Follow existing repo conventions before introducing new structure.
- Keep errors explicit; do not rely on silent fallback behavior.
- Preserve single-responsibility boundaries unless the task brief or repo constraints justify a combined unit.
- Avoid duplicating rules, defaults, variant lists, schemas, or operational mappings when one authoritative source can stay clear.
- For configuration, scripting, and Nix-heavy work, prefer KISS, DRY, explicit contracts, single choice, self-documentation, and least astonishment.

## Standards Sources

- Use `dotfiles/common/.codex/rules/design-standards.md` for TypeScript, Python, general, shell, and configuration-heavy implementation guidance.
- Use `dotfiles/common/.codex/rules/rust-design-standards.md` for Rust-specific implementation guidance.
- Record repo-specific overrides and any allowed deviations in implementation notes.

## Validation Order

Run the smallest relevant checks in this order when applicable:

1. formatter check
2. linter check
3. type or LSP-equivalent check
4. build or compile check
5. targeted tests for changed behavior
6. broader tests when risk or scope requires

If a tool is unavailable, report it explicitly with confidence impact.

## Failure Handling

- Classify failures as `introduced`, `pre-existing`, `environment`, or `scope-expanding`.
- Self-fix only failures caused by the current edits and inside the approved scope.
- Escalate when an environment blocker, pre-existing failure, or required out-of-scope edit prevents safe completion.
- Escalate when satisfying the task would mix unrelated responsibilities or duplicate authoritative knowledge outside allowed deviations.
