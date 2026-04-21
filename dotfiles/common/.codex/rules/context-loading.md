# Context Loading Rules

Load context in this order and stop as soon as the task is sufficiently grounded:

1. global `AGENTS.md`
2. active role config
3. task-relevant reusable rules
4. task-local repo files
5. skill references only when the skill is actually triggered

Rules:
- Do not load every role config into one thread.
- Do not bulk-load reference directories.
- Prefer compact task briefs and context digests over full thread history.
- Use `fork_context=true` only when a narrow same-scope follow-up cannot be expressed cleanly.
