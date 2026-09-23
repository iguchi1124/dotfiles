---
title: {{PROJECT_TITLE_YAML}}
---

# Tasks

Shared directory: `{{COORDINATION_DIR}}`
Allowed states: `backlog`, `ready`, `active`, `blocked`, `review`, `done`.

## Coordinator ownership and handoff

- Writer session: unclaimed (acquire `.writer-lock` before editing)
- Updated: {{CREATED_AT}}
- Next action: establish requirements and task assignments
- Active agent sessions: none

## Task entry

Replace this example with real tasks. The coordinator reserves scope before
delegation. Blocked and review tasks retain ownership until an explicit handoff.

### TASK-NNN — Outcome

- Status: backlog
- Dependencies: none
- Owner/session: unassigned
- Updated: {{CREATED_AT}}
- Scope: TBD (files, interfaces, or responsibility)
- Worktree/branch: unassigned
- Task record: unassigned (absolute path; detailed plan, baseline, and evidence live there)
- Done when: TBD
- Verification: TBD
- Outcome/next action: TBD (include integration status)
- Blocker/restart condition: none
- Handoff: none
