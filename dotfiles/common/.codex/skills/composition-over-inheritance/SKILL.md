---
name: composition-over-inheritance
description: Prefer composition for reusable behavior in mixed-language and config-heavy repos. Use when generating, reviewing, or designing modules, helpers, configs, CI steps, or components and deciding whether has-a relationships, delegation, or assembly are cleaner than inheritance or deep hierarchy reuse. Flag inheritance used only for reuse, hierarchy explosion, fragile base classes, and cases where delegation or smaller components would be simpler.
---

# Composition Over Inheritance

Prefer `has-a` before `is-a` when generating or refactoring reusable behavior.

Review reusable behavior with these checks:

- Ask whether inheritance is being used only to reuse code rather than to model a true subtype.
- Look for hierarchy growth where each new variant adds another subclass, override, or special-case branch.
- Look for fragile base classes where shared defaults, lifecycle hooks, or implicit ordering make changes risky.
- Prefer delegation, helper modules, composable Nix modules, shell functions, config includes, or CI step assembly when they keep behavior local and understandable.

Apply this beyond OOP:

- Compose Nix modules instead of encoding behavior in broad parent modules.
- Compose shell helpers instead of stacking wrappers that inherit side effects.
- Compose app configs from small focused units instead of cloning and mutating large base files.
- Compose CI jobs and steps from reusable pieces instead of deep template chains.

When suggesting a change, move shared behavior into a focused dependency and keep the public contract explicit at the point of assembly.
