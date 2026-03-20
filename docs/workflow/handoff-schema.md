# Workflow Handoff Schema

This schema is runtime-neutral and shared by all adapters.

## Required Global Fields

- `task_id`
- `stage`
- `goal`
- `assumptions`
- `constraints`
- `risk_tier` (`low | medium | high`)
- `touched_areas`
- `decisions`
- `open_questions`
- `next_agent`
- `review_cycle_count`
- `skip` object
- `escalation` object
- `skill_used`
- `mcp_used`
- `external_calls`
- `trust_notes`

`standards_profile` is an optional global field in the shared schema and is required for Rust-routed tasks in v1.

## Optional Global Fields

- `standards_profile`

## `skip` Object

- `applied` (boolean)
- `stage_name` (string)
- `skip_reason` (string)

## `escalation` Object

- `required` (boolean)
- `reason` (string)
- `risk_if_unchanged` (string)
- `recommended_alternative` (string)
- `question_for_human` (string)
- `blocking` (boolean)

## `standards_profile` Object

- `language` (string)
- `profile_name` (string)
- `applied_rules` (array of strings)
- `repo_overrides` (array of strings)
- `deviations_allowed` (array of strings)

## Stage Specific Required Fields

- analyzer:
  - `problem_statement`
  - `acceptance_criteria`
- researcher:
  - `code_map`
  - `existing_patterns`
  - include `standards_profile` recommendations when the task is language-routed
- planner:
  - `execution_plan`
  - `validation_plan`
  - `agent_selection`
  - include bound `standards_profile` when the selected agent is language-specific
- coder:
  - `change_log`
  - `implementation_notes`
- reviewer:
  - `review_outcome` (`approved | changes_required | blocked`)
  - `fix_instructions`
  - `severity_summary`
- tester:
  - `test_results`
  - `coverage_notes`
  - `confidence`
- technical-writer:
  - `docs_changed`
  - `user_impact`
- summarizer:
  - `structured_summary`
  - `narrative_summary`
  - `residual_risks`
  - `skipped_stages`

## `fix_instructions` Format

Each item must include:

- `issue`
- `impact`
- `required_change`
- `acceptance_check`

## Minimal Example

```json
{
  "task_id": "wf-123",
  "stage": "reviewer",
  "goal": "Implement feature X",
  "assumptions": ["A", "B"],
  "constraints": ["No schema changes"],
  "risk_tier": "medium",
  "touched_areas": ["src/x.ts"],
  "decisions": ["Use existing service pattern"],
  "open_questions": [],
  "next_agent": "typescript-coder",
  "review_cycle_count": 1,
  "standards_profile": {
    "language": "typescript",
    "profile_name": "service-default",
    "applied_rules": [],
    "repo_overrides": [],
    "deviations_allowed": []
  },
  "review_outcome": "changes_required",
  "fix_instructions": [
    {
      "issue": "Missing null guard",
      "impact": "Potential runtime crash",
      "required_change": "Validate input before dereference",
      "acceptance_check": "Unit test covers null input"
    }
  ],
  "severity_summary": "1 medium issue",
  "skip": {
    "applied": false,
    "stage_name": "",
    "skip_reason": ""
  },
  "escalation": {
    "required": false,
    "reason": "",
    "risk_if_unchanged": "",
    "recommended_alternative": "",
    "question_for_human": "",
    "blocking": false
  },
  "skill_used": ["typescript-skillpack"],
  "mcp_used": [],
  "external_calls": [],
  "trust_notes": "No external write actions"
}
```
