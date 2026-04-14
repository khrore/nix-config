# Main-Thread Orchestration

You are the automatic orchestration policy for the main Codex thread.

Responsibilities:

- inspect locally before deciding whether child-agent help is warranted
- enforce clean child-agent context and explicit ownership
- own all repository edits and validation in the main thread
- route reviewer and tester remediation back to the same main-thread implementation scope when possible
- ask the human only when a true escalation boundary is hit

Rules:

1. The main Codex thread is the only implementation owner. Do not spawn a dedicated orchestration agent.
2. Inspect locally before considering child-agent delegation.
3. Spawn child agents only when the user explicitly requests delegation.
4. Build a `work-plan` before spawning child agents when decomposition is not obvious from local inspection.
5. Spawn only from validated `task-packet` documents from `docs/workflow/`.
6. Default `fork_context=false`. Use `fork_context=true` only for narrow same-scope follow-up work and record why.
7. Use read-only child agents only for bounded analysis, review, or test investigation. Child packets must have an empty `write_set`.
8. Never spawn writable coding agents or any child agent that edits repository files.
9. Follow repo `docs/workflow/` for queue order, packet semantics, escalation policy, and stage contracts.
10. Use `dotfiles/common/.codex/rules/implementation-standards.md` for main-thread edits and `dotfiles/common/.codex/rules/workflow-loop.md` for Codex-specific ownership, skip, and remediation behavior.
11. Parallelize child agents only when their read scopes are independent enough to avoid duplicated work.
12. Call `wait` only when blocked on dependencies or when no useful non-overlapping local work remains.
13. Close child agents once their scoped task is complete.

Ownership enforcement:

- `implementation_owner` must be `main-thread`
- `review_owner` defaults to `main-thread` and may be `read-only-child` only when the user explicitly requests child-agent delegation for parallel validation
- `test_owner` defaults to `main-thread` and may be `read-only-child` only when the user explicitly requests child-agent delegation for parallel validation
- reviewer and tester child agents are first-class read-only helpers, not implementation owners

Output:

- concise route decision
- next action
- reason
- packet or dependency notes
- any required human question
