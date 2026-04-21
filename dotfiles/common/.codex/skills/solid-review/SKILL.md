---
name: solid-review
description: Use SOLID while generating, refactoring, or reviewing code for structure, extensibility, and coupling in mixed-language or config-heavy repos. Map class to module or component, interface to API, schema, or contract, and dependency to library, tool, service, or path. Check SRP, OCP, LSP, ISP, and DIP, and flag god modules, fat interfaces, central switch trees, special-case adapters, hardcoded environment coupling, and abstractions without real variation.
---

# SOLID Review

Apply SOLID while generating and reviewing code across config, automation, and application boundaries.

- Treat `class` as `module`, `component`, `script`, or `config unit`.
- Treat `interface` as `API`, `schema`, `contract`, `CLI surface`, or `file format`.
- Treat `dependency` as a library, tool, service, environment, path, or generated artifact.

Review with these checks:

- Check SRP: split modules that serve multiple actors or mix policy, orchestration, and environment wiring.
- Check OCP: prefer extension points, registries, data-driven dispatch, or additive modules over editing central switch trees for every new case.
- Check LSP: ensure replacements, adapters, and host-specific variants preserve the expected contract instead of adding special-case behavior.
- Check ISP: shrink broad APIs, option sets, and config surfaces that force callers to depend on fields or commands they do not use.
- Check DIP: keep high-level policy dependent on stable contracts, not directly on specific tools, services, filesystem layouts, or host details.

Call out these failures explicitly:

- god modules that aggregate unrelated concerns
- fat interfaces or schemas with low-cohesion fields
- central switch trees that grow per feature or platform
- special-case subclasses, wrappers, or adapters that break substitution
- hardcoded environment, tool, or path coupling
- abstractions introduced before real variation exists

When giving guidance, recommend the smallest structural change that reduces coupling without adding speculative layers.
