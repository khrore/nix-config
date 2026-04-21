---
name: law-of-demeter
description: Apply the Law of Demeter while generating, refactoring, or reviewing code in mixed-language or config-heavy repos. Use when code reaches through nested objects, crosses boundaries casually, or couples one layer to internals owned by another.
---

# Law of Demeter

Apply this skill when generating or reviewing boundaries in a mixed-language or configuration-heavy repo.

- Let a unit talk to itself, its direct inputs, directly owned collaborators, and values it creates.
- Avoid reach-through access and layer skipping.
- Optimize for lower coupling, not literal dot-count.

When reviewing:

- Flag chained calls, deep property access, and cross-boundary traversal.
- Flag modules that bypass their immediate boundary to read distant config, service state, or nested infrastructure objects.
- Treat shell scripts, Nix modules, YAML, JSON, and application code the same: avoid wiring one layer to internals owned by another.
- Prefer interfaces that expose the needed value directly instead of requiring callers to navigate object graphs.

When proposing changes:

- Introduce narrow parameters, helper methods, or facades at the boundary that owns the knowledge.
- Move traversal logic next to the data it navigates.
- Pass stable values instead of rich objects when only a small slice is needed.
- Reduce coupling even if a short call chain remains.
