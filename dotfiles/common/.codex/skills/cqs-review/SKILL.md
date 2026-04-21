---
name: cqs-review
description: Apply command-query separation while generating, refactoring, or reviewing callable boundaries in mixed-language and config-heavy repos so operations either mutate state or return information, with explicit plan/apply or validate/fix splits and only documented exceptions for atomicity or concurrency.
---

# CQS Review

Use this skill when generating or reviewing functions, methods, scripts, commands, hooks, and config-driven actions.

- Separate commands from queries. A callable should mutate state or return information, not both.
- Flag query-shaped operations that write files, update caches, alter globals, emit network calls, or mutate config as a side effect.
- Flag command-shaped operations that double as reads and become hard to reason about in tests, retries, or automation.
- Look for places where an explicit split would clarify behavior: `plan` and `apply`, `validate` and `fix`, `check` and `write`.
- Treat return values from commands carefully. Status, ids, or summaries are fine; hidden data reads coupled to mutation are not.
- Review CLI and config flows for dry-run parity. If a tool mutates, make the read-only path explicit.
- Allow exceptions only when atomicity or concurrency requires one operation. Demand that the exception is documented and obvious at the call site.
- Prefer names that reveal whether the operation reads, writes, or does both by exception.
