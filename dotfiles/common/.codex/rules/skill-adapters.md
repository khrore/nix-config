# Skill Adapter Rules

Skills are optional task-local extensions. They are not part of the global policy kernel.

Use a skill only when:
- its metadata clearly matches the task
- it adds information or tooling the active role does not already have

Adapter rules:
1. Orchestrator or planner decides whether a skill is relevant.
2. Skill use must be represented in the task `context_digest` or packet constraints.
3. Load only the skill body and the specific references needed for the task.
4. Do not copy full skill instructions into role prompts or packets.
5. Skills may refine a task, but they do not override higher-precedence policy.
