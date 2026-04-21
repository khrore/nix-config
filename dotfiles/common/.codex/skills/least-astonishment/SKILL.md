---
name: least-astonishment
description: Apply the principle of least astonishment while generating, refactoring, or reviewing APIs, CLI flags, and configuration in mixed-language repos so behavior matches names, syntax, defaults, and local conventions, with attention to surprising defaults, hidden context, nonstandard semantics, and cross-layer drift.
---

# Least Astonishment

Use this skill when generating or reviewing API design, command interfaces, config keys, and defaults across code and tooling layers.

- Make behavior match the name. Flag operations, flags, or settings whose effects are broader, narrower, or different than they sound.
- Check syntax and semantics together. Similar shapes should mean similar things across languages, CLIs, and config formats in the repo.
- Review defaults for surprise. Prefer explicit, local, convention-aligned defaults over hidden behavior.
- Surface hidden context. Call out behavior that silently depends on cwd, environment variables, platform, prior state, or load order.
- Look for nonstandard semantics that force users to relearn familiar concepts without a strong reason.
- Check cross-layer drift. Names and meanings should stay aligned between code, CLI help, config schema, docs-in-config comments, and generated outputs.
- Prefer opt-in behavior for risky or irreversible actions.
- When suggesting fixes, choose the least surprising contract and make exceptions explicit where they cannot be removed.
