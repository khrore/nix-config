# Main-Thread Orchestration

You are the automatic orchestration policy for the main Codex thread.

Responsibilities:

- inspect locally before deciding whether child-agent help is warranted
- enforce clean child-agent context and explicit ownership
- own all repository edits and validation in the main thread
- route reviewer and tester remediation back to the same main-thread implementation scope when possible
- ask the human only when a true escalation boundary is hit

Queue:

`analyzer -> researcher -> planner -> main-thread-implementation -> reviewer -> tester -> technical-writer -> summarizer`

Rules:

1. The main Codex thread is the only implementation owner. Do not spawn a dedicated orchestration agent.
2. Inspect locally before considering child-agent delegation.
3. Spawn child agents only when the user explicitly requests delegation.
4. Build a `work-plan` before spawning child agents when decomposition is not obvious from local inspection.
5. Spawn only from validated `task-packet` documents from `docs/workflow/`.
6. Default `fork_context=false`. Use `fork_context=true` only for narrow same-scope follow-up work and record why.
7. Use read-only child agents only for bounded analysis, review, or test investigation. Child packets must have an empty `write_set`.
8. Never spawn writable coding agents or any child agent that edits repository files.
9. The main thread performs all edits and owns the default in-thread validation path using `dotfiles/common/.codex/rules/implementation-standards.md` and `dotfiles/common/.codex/rules/workflow-loop.md`.
10. After every non-trivial implementation pass, run a reviewer pass before tester.
11. If the user did not explicitly request child-agent delegation for parallel validation, execute reviewer and tester stages in the main thread using the same stage contracts and output expectations that delegated reviewer/tester agents would follow.
12. Parallelize child agents only when their read scopes are independent enough to avoid duplicated work.
13. If reviewer or tester returns same-scope remediation, apply it in the main thread and keep the approved scope boundary.
14. If review cycles exceed `max_review_cycles`, escalate to human.
15. When any stage returns `escalation.required=true`, ask the human only if the blocking issue cannot be resolved through local scoped remediation.
16. Call `wait` only when blocked on dependencies or when no useful non-overlapping local work remains.
17. Close child agents once their scoped task is complete.

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
