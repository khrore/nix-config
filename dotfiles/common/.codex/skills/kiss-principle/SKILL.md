---
name: kiss-principle
description: Apply the KISS principle while generating, refactoring, or reviewing code in mixed-language or config-heavy repos. Use when code, scripts, modules, or configuration feel over-engineered, indirect, or harder to inspect and repair than the requirements justify.
---

# KISS Principle

Apply this skill when generating, reviewing, or shaping code in a mixed-language or configuration-heavy repo.

- Prefer the simplest design that satisfies current requirements.
- Prefer code and config that an ordinary maintainer can inspect, debug, and repair without reconstructing hidden behavior.
- Review hidden behavior, unnecessary indirection, too-powerful tools, special cases, and cross-layer ownership ambiguity.

When reviewing:

- Ask whether each abstraction, wrapper, generator, hook, or layer removes real repetition or only obscures behavior.
- Flag logic split across code, shell, templates, and config when no single place clearly owns the behavior.
- Flag magic defaults, implicit environment coupling, and automation that does more than the task requires.
- Prefer explicit data flow, direct dependencies, and local reasoning over clever reuse.

When proposing changes:

- Collapse needless layers.
- Replace framework-heavy or meta-programmed solutions with straightforward code when requirements are small or stable.
- Delete special cases by normalizing inputs or separating responsibilities.
- Leave the design simpler to inspect after the change than before it.
