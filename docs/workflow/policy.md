# Workflow Policy

## Risk Tiers

- low: local docs/refactor/non-behavioral change
- medium: behavior change in existing module
- high: security, persistence, concurrency, migrations, public interfaces

## Escalation Policy

User chooses one mode when creating workflow:

- strict
- balanced
- relaxed

### strict

- block on medium and high concerns

### balanced

- high: always block
- medium:
  - block at planner/reviewer/tester
  - non-blocking ask at analyzer/researcher/technical-writer/summarizer

### relaxed

- block only on critical/high-impact concerns

## Reviewer Loop Policy

- reviewer returns `approved`, `changes_required`, or `blocked`
- `changes_required` must include structured `fix_instructions`
- workflow loops to the same implementation owner
- stop after `max_review_cycles` and escalate to human
- in the Codex adapter, reviewer and tester run in the main thread by default and may use read-only child helpers only when the user explicitly requests child-agent delegation for parallel validation

## Skip Policy

- low risk may skip tester for docs-only or non-behavioral work with explicit `skip_reason`
- technical-writer may no-op when no docs impact
- high risk cannot skip reviewer or tester

## Skills and MCP Policy

- default deny for mutation-capable external operations
- external read-only requests are allowed
- external write/mutation follows escalation policy and risk gates
- every stage must report `skill_used`, `mcp_used`, and `external_calls`
