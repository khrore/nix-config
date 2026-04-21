---
name: dry-principle
description: Use DRY while generating, refactoring, or reviewing code in mixed-language or config-heavy repos. Keep one authoritative representation for change-prone knowledge such as rules, versions, paths, schemas, option lists, and behavior descriptions. Review for duplicated logic and for drift across docs, tests, CI, and config, but avoid premature abstraction when duplication is harmless and clarity matters more.
---

# DRY Principle

Keep one authoritative representation for change-prone knowledge while generating and reviewing changes.

Review with these checks:

- Find repeated rules, versions, paths, schemas, option lists, and environment assumptions across code, config, scripts, tests, docs, and CI.
- Check whether the same behavior is described or encoded in multiple places and is likely to drift during normal maintenance.
- Prefer generating, referencing, or importing shared knowledge from one source when the duplication is costly to update correctly.
- Keep harmless duplication when the shared abstraction would hide intent, distort ownership, or couple unrelated changes.

Call out these failure modes:

- docs, tests, CI, and config that describe different behavior
- duplicated schemas or option lists with independent edits
- repeated paths, versions, or environment rules that must change together
- abstractions created too early that are harder to read than the duplication they replace

When recommending a fix, preserve clarity first and remove only the duplication that carries real change risk.
