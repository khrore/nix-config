# Packet Authoring Rules

Every non-trivial delegated task should be described by a schema-valid packet.

A good packet must define:
- one role
- one objective
- explicit read set
- explicit write set
- constraints
- acceptance checks
- tool commands
- stop conditions
- escalation conditions
- dependencies
- context digest
- expected output format

Rules:
- Keep packets small enough for local reasoning.
- Do not assign overlapping write sets to parallel tasks.
- Use reviewer and tester packets as independent gates, not as coder extensions.
- Prefer concrete file paths and concrete commands over generic phrasing.
