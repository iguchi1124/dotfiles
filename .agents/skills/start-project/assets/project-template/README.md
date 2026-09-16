---
title: {{PROJECT_TITLE_YAML}}
scope: "Index, editing rules, and current status for the project documents"
---

# {{PROJECT_NAME}}

TBD (describe the project in one or two sentences)

## Document structure

Treat each file as the source of truth for its responsibility. Do not duplicate the
same requirement across multiple files.

| File | Responsibility | Audience |
|---|---|---|
| `project.md` | Background, goals, requirements, scope, and open questions | Entire project |
{{COMPONENT_ROWS}}
| `tasks.md` | Task breakdown, priority, dependencies, and progress | Implementers |

Components: {{COMPONENT_LIST}}

## Editing rules

- Describe the current agreement rather than maintaining a change log.
- Keep details in the responsible file and reference them elsewhere without duplication.
- Leave unknown decisions as `TBD` instead of guessing.
- Do not include real user data, credentials, or secrets.
- Follow repository-specific instructions when they impose additional requirements.

## Current status

- Status: Draft
- TBD (decisions made, active research, or items awaiting review)
