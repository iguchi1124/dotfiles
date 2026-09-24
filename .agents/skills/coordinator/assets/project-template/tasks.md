---
title: {{PROJECT_TITLE_YAML}}
---

# Tasks

Shared directory: `{{COORDINATION_DIR}}`
Allowed states: `backlog`, `ready`, `active`, `blocked`, `review`, `done`.

## Coordinator ownership and handoff

- Coordinator session: unclaimed
- Updated: {{CREATED_AT}}
- Next action: establish requirements and task assignments
- Active agent sessions: none

## Task entry

Replace this example with real tasks. The coordinator reserves scope and records
the task ID and execution paths before marking a task ready. A user invokes the
executor separately with that ID. Blocked and review tasks retain ownership until
an explicit handoff.

### TASK-NNN — Outcome

- Status: backlog
- Dependencies: none
- Dependency base/evidence: TBD (required changes must be present before starting)
- Owner/session: unassigned
- Updated: {{CREATED_AT}}
- Scope: TBD (files, interfaces, or responsibility)
- Worktree/branch: unassigned (set both before ready)
- Base commit/pre-existing changes: TBD
- Done when: TBD (include required integration; stay in review while it is outstanding)
- Verification: TBD
- Outcome/next action: TBD (include integration status)
- Blocker/restart condition: none
- Handoff: none
