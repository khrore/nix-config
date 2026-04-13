# AGENTS.md - Multiagent Workflow Playbook

- Audience: Workflow agents under this directory.
- Purpose: Shared context and quality-of-life conventions for clean handoffs.
- Scope: Coordination guidance only. Role behavior and routing rules live in each agent file.

---

## 1) What this file is (and is not)

Use this file as a lightweight playbook to keep stage outputs consistent and easy to consume.

This file does not replace:

- `main-thread-orchestration.md` for queue control and loop routing by the main Codex thread
- stage prompts (`analyzer`, `researcher`, `planner`, `reviewer`, `tester`, `technical-writer`, `summarizer`) for role-specific rules
- workflow docs in `docs/workflow/` for canonical schema and policy definitions
- parent `../AGENTS.md` for shared engineering standards
- `../rules/implementation-standards.md` for main-thread implementation rules

If there is a conflict, follow the shared workflow docs first, then the stage prompt, then this playbook.

---

## 2) Workflow orientation (quick map)

Default queue:

`analyzer -> researcher -> planner -> main-thread-implementation -> reviewer -> tester -> technical-writer -> summarizer`

Codex operating model:

- the main Codex thread handles decomposition, edits, validation, and result merging
- child agents are read-only and should receive validated task packets from `docs/workflow/`
- spawn child agents only when the user explicitly requests delegation
- child agents must have an empty `write_set`
- `fork_context=false` is the default unless a narrow follow-up requires inherited context

Common loop:

- reviewer returns `changes_required`
- route back to the main thread implementation owner with actionable `fix_instructions`
- repeat until approved or review-cycle limit is reached

Escalation is context-driven via workflow settings (for example `escalation_policy`, `max_review_cycles`).

---

## 3) Handoff quality defaults

Every handoff should be easy for the next stage to execute without guessing.

- Keep outputs concise and structured; prefer short lists over long prose.
- Prefer packet fields and evidence over free-form narrative summaries.
- State assumptions explicitly; do not hide them in narrative text.
- Call out unknowns that can change implementation behavior.
- Include evidence references (files, checks, observations), not just conclusions.
- If work is skipped, state what was skipped and why.
- Report scoped `read_set` boundaries whenever child work is delegated.
- Keep delegated `write_set` empty for every child-agent packet.

Recommended status vocabulary:

- `ready`: stage finished and handoff is complete
- `needs_human`: stage cannot continue without a decision
- `blocked`: cannot proceed due to missing input, tooling, or precondition
- `changes_required`: reviewer requests implementation remediation
- `done`: terminal completion, typically summarizer

---

## 4) Escalation communication style

When asking a human question, keep it decision-ready:

1. One clear question
2. Why this decision matters now
3. Recommended default
4. What changes based on each choice

Avoid broad or multi-part questions that delay routing.

---

## 5) Reviewer -> implementation remediation quality

`fix_instructions` should be actionable and verifiable.

Good `fix_instructions` are:

- specific to files and behaviors
- minimal in scope
- testable with clear acceptance checks
- ordered when steps depend on each other

Avoid:

- vague feedback such as "improve quality" or "clean this up"
- mixed unrelated requests in one item
- requirements without validation criteria

Example, good:

`In src/cache.ts, handle TTL parse failures by returning a typed error instead of defaulting to 0; add a test that asserts invalid TTL returns ConfigError::InvalidTtl.`

Example, bad:

`Caching is risky; please make it safer.`

---

## 6) Stage collaboration etiquette

- Respect prior stage decisions unless new evidence shows risk or contradiction.
- Do not re-scope the task without a concrete reason.
- Preserve useful context from upstream; do not force downstream stages to rediscover it.
- Prefer smallest-change guidance that still satisfies acceptance criteria.
- Keep language neutral and operational; avoid performative commentary.
- Reuse an existing child agent only for same-scope follow-up analysis; start a fresh child for unrelated work.
- Close child agents when their scoped task is complete instead of letting them accumulate stale context.

---

## 7) Practical checklists (non-binding reminders)

Analyzer:

- restate objective clearly
- list assumptions and constraints
- define acceptance criteria and risk framing

Researcher:

- map relevant files and systems
- capture existing patterns and constraints
- flag unknowns that affect plan viability

Planner:

- produce executable steps
- align validation depth with risk
- choose whether read-only child analysis is useful enough to justify spawning
- split into bounded work items with clear ownership and dependencies

Main-thread implementation:

- follow `../rules/implementation-standards.md`
- implement only approved scope
- keep changes focused and reversible
- report exactly what changed
- run the required validation loop before handoff

Reviewer:

- decide: approved, changes_required, or blocked
- provide concrete remediation when not approved
- include acceptance checks for each fix item
- review the result against the task packet, not against the whole thread

Tester:

- validate behavior and failure paths
- separate pass/fail from confidence notes
- report residual risk when coverage is partial

Technical writer:

- update impacted docs only
- keep docs concise and task-scoped
- no-op explicitly when docs impact is zero

Summarizer:

- produce structured and human summaries
- include validation, assumptions, and residual risks
- clearly mark skipped stages and reasons

---

## 8) Token and readability hygiene

- Prefer compact, high-signal outputs.
- Avoid repeating unchanged context from earlier stages.
- Use stable field names and ordering when possible.
- Keep examples short and directly relevant to the active task.
- Prefer task packets, work plans, and implementation/review results from `docs/workflow/` over ad hoc prompt prose.

This playbook is intentionally lightweight. Add guidance here only when it improves cross-stage clarity.
