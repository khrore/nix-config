---
name: encapsulation-lens
description: Apply encapsulation while generating, refactoring, or reviewing code in mixed-language or config-heavy repos so state stays with the operations that maintain it, internals stay behind stable interfaces, and consumers do not rely on private attributes or incidental defaults.
---

# Encapsulation Lens

Use this skill when generating or reviewing module boundaries, public APIs, or config contracts.

- Keep state with the code that maintains its invariants.
- Reduce direct access to internals. Push callers toward stable interfaces instead of reach-in reads or writes.
- Inspect the exported surface first. Flag modules, classes, functions, CLI outputs, or config schemas that expose more than consumers need.
- Check mutation boundaries. Require invariants to be enforced where state changes, not by scattered callers.
- Look for internal reach-in across files, layers, or config consumers. Treat access to private attrs, internal paths, cache files, or incidental object shape as a design smell.
- Check whether config consumers depend on undocumented defaults or private fields instead of explicit settings.
- Prefer narrow, named interfaces over broad object sharing.
- When suggesting changes, preserve stable contracts and move volatile details inward.
