# Adapter Mapping Tables

## Role to Capability

| Role | read_files | search_code | edit_code | run_checks | external_read | external_write | orchestrate_subagents |
|---|---:|---:|---:|---:|---:|---:|---:|
| workflow-orchestrator | yes | yes | no | no | yes | no | yes |
| analyzer | yes | yes | no | no | yes | no | no |
| researcher | yes | yes | no | no | yes | no | no |
| planner | yes | yes | no | yes | yes | no | no |
| python-coder | yes | yes | yes | yes | yes | policy-gated | no |
| rust-coder | yes | yes | yes | yes | yes | policy-gated | no |
| vue-coder | yes | yes | yes | yes | yes | policy-gated | no |
| typescript-coder | yes | yes | yes | yes | yes | policy-gated | no |
| general-coder | yes | yes | yes | yes | yes | policy-gated | no |
| python-reviewer | yes | yes | no | yes | yes | no | no |
| rust-reviewer | yes | yes | no | yes | yes | no | no |
| vue-reviewer | yes | yes | no | yes | yes | no | no |
| typescript-reviewer | yes | yes | no | yes | yes | no | no |
| general-reviewer | yes | yes | no | yes | yes | no | no |
| tester | yes | yes | no | yes | yes | no | no |
| technical-writer | yes | yes | docs-only | no | yes | no | no |
| summarizer | yes | yes | no | no | yes | no | no |

## Capability to OpenCode

| Capability | OpenCode mapping |
|---|---|
| read_files | `read`, `glob`, `grep` |
| search_code | `glob`, `grep` |
| edit_code | `write`, `edit`, `apply_patch` |
| run_checks | `bash` command allowlists |
| external_read | `webfetch` allow, read-only MCPs |
| external_write | MCP mutation tools with policy gate |
| orchestrate_subagents | `task` tool with `permission.task` |

## Capability to Codex Runtime

| Capability | Codex mapping |
|---|---|
| read_files | filesystem read/search tools |
| search_code | glob/grep equivalents |
| edit_code | patch/edit/write tools in the main thread only |
| run_checks | shell tool command allowlists, typically in the main thread |
| external_read | web/read-only integration access |
| external_write | integration mutation permissions with gate |
| orchestrate_subagents | read-only subagent task invocation API on explicit user request |

## Capability to Claude Runtime

| Capability | Claude mapping |
|---|---|
| read_files | read/search tool permissions |
| search_code | file/content search tools |
| edit_code | write/edit permissions per agent |
| run_checks | terminal command permissions |
| external_read | web or MCP read permissions |
| external_write | MCP mutation permissions with gate |
| orchestrate_subagents | allowed child-agent invocation policy |

## Routing Enforcement

| Rule | OpenCode | Codex | Claude |
|---|---|---|---|
| fixed queue | `permission.task` + orchestrator prompt | orchestrator router + read-only child allowlist + main-thread implementation owner | agent policy + allowed child list |
| reviewer loop | payload `review_cycle_count` | session state counter | session state counter |
| max cycles | workflow config override | workflow config override | workflow config override |
| escalation | `escalation_policy` in payload | same | same |
| hidden orchestrator | `hidden: true` | internal-only marker | hidden/internal config |
| language standards | shared `standards_profile` payload + shared standards references | same | same |
