# Workflow Loop Rules

Use this file as the authoritative definition of the Codex validation loop.

## Ownership Model

- the main Codex thread is always the implementation owner
- reviewer and tester stages exist for every non-trivial task
- reviewer and tester run in the main thread by default
- reviewer or tester child agents are optional read-only helpers used only when the user explicitly requests child-agent delegation for parallel validation
- every child-agent packet for reviewer or tester work must keep `write_set` empty

## Default Loop

For non-trivial work, execute stages in this order:

1. main-thread implementation
2. reviewer pass
3. tester pass
4. technical-writer when docs impact exists
5. summarizer

If delegation is not user-authorized, the main thread must execute reviewer and tester stages using the same role contracts and output expectations that delegated reviewer/tester agents would follow.

## Mandatory Reviewer Cases

Reviewer is mandatory when:

- behavior changes
- validation failures need classification or remediation direction
- risk tier is `medium` or `high`
- scope includes public interfaces, persistence, concurrency, security, or migrations

Reviewer may be skipped only for trivial, non-behavioral work when the skip is explicitly recorded and the task packet or user request makes the skip low-risk.

## Mandatory Tester Cases

Tester is mandatory when:

- behavior changes
- risk tier is `medium` or `high`
- reviewer approved code that still requires command evidence
- the task packet or repo policy requires validation before handoff

Tester may be skipped only for low-risk docs-only or non-behavioral work with an explicit `skip_reason`.

## Reviewer Remediation Loop

When reviewer returns `changes_required`:

1. route remediation back to the same main-thread implementation owner
2. keep the approved scope boundary unless escalation is required
3. increment `review_cycle_count`
4. rerun reviewer before tester
5. escalate to human if `review_cycle_count` exceeds `max_review_cycles`

If reviewer returns `blocked`, ask the human only when the blocking issue cannot be resolved through local scoped remediation.

## Tester Expectations

- run checks in the packet-defined order unless environment reality forces a safer order
- report exact commands with pass/fail status
- classify failures as `introduced`, `pre-existing`, `environment`, or `scope-expanding`
- send same-scope fixes back to the main-thread implementation owner
- state skipped checks and confidence impact explicitly

## Planner Assignment Expectations

For every non-trivial implementation task, `agent_selection` must assign:

- `implementation_owner`
- `review_owner`
- `test_owner`

For the Codex adapter:

- `implementation_owner` must be `main-thread`
- `review_owner` defaults to `main-thread`
- `test_owner` defaults to `main-thread`
- `review_owner` or `test_owner` may be `read-only-child` only when the user explicitly requested child-agent delegation for parallel validation
