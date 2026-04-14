# AGENTS.md - Multiagent Workflow Playbook

- Audience: Workflow agents under this directory.
- Purpose: Shared context and quality-of-life conventions for clean handoffs.
- Scope: Coordination guidance only. Canonical workflow semantics live in repo `docs/workflow/`.

---

## 1) Canonical Sources

Use this file to keep stage handoffs compact and consistent.

Authoritative references:

- repo `docs/workflow/` for queue, ownership, escalation, skip policy, packets, and failure taxonomy
- parent `../AGENTS.md` for shared engineering standards and reporting requirements
- runtime-specific agent prompts for OpenCode tool and ownership behavior

If there is a conflict, follow the workflow docs first, then the stage prompt, then this playbook.

---

## 2) Handoff Quality Defaults

Every handoff should be easy for the next stage to execute without guessing.

- Keep outputs concise and structured; prefer short lists over long prose.
- Prefer packet fields and evidence over free-form narrative summaries.
- State assumptions explicitly; do not hide them in narrative text.
- Call out unknowns that can change implementation behavior.
- Include evidence references (files, checks, observations), not just conclusions.
- If work is skipped, state what was skipped and why.
- Report scoped `read_set` and `write_set` boundaries whenever child work is delegated.

Recommended status vocabulary:

- `ready`: stage finished and handoff is complete
- `needs_human`: stage cannot continue without a decision
- `blocked`: cannot proceed due to missing input, tooling, or precondition
- `changes_required`: reviewer requests coder remediation
- `done`: terminal completion, typically summarizer

---

## 3) Escalation Communication

When asking a human question, keep it decision-ready:

1. One clear question
2. Why this decision matters now
3. Recommended default
4. What changes based on each choice

Avoid broad or multi-part questions that delay routing.

---

## 4) Remediation Quality

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

## 5) Collaboration Etiquette

- Respect prior stage decisions unless new evidence shows risk or contradiction.
- Do not re-scope the task without a concrete reason.
- Preserve useful context from upstream; do not force downstream stages to rediscover it.
- Prefer smallest-change guidance that still satisfies acceptance criteria.
- Keep language neutral and operational; avoid performative commentary.
- Reuse an existing child agent only for same-scope remediation; start a fresh child for unrelated work.
- Close child agents when their scoped task is complete instead of letting them accumulate stale context.

---

## 6) Token And Readability Hygiene

- Prefer compact, high-signal outputs.
- Avoid repeating unchanged context from earlier stages.
- Use stable field names and ordering when possible.
- Keep examples short and directly relevant to the active task.
- Prefer task packets, work plans, and worker results from `docs/workflow/` over ad hoc prompt prose.

This playbook is intentionally lightweight. Add guidance here only when it improves cross-stage clarity.
