---
title: {{PROJECT_TITLE_YAML}}
status: active
scope: "Task dependencies, ownership, work boundaries, and verification"
---

# Tasks

Allowed states: `backlog`, `ready`, `active`, `blocked`, `review`, `done`.

The parent coordinator is the only writer to this file. Record assignment before
delegation. `blocked` and `review` retain ownership; reassign only through an explicit
handoff. Run tasks in parallel only when dependencies are done and scopes do not
overlap.

## TASK-001 — Establish the executable project plan

- Status: ready
- Depends on: none
- Owner/session: coordinator
- Started/updated: {{CREATED_AT}}
- Responsibility: Refine `project.md` and `spec.md`; replace this seed task with the executable task graph.
- Files or systems: `.claude/coordinator/{{RUN_NAME}}/`
- Worktree/branch: current project root / current branch
- Done when: Requirements, dependencies, task boundaries, and verification are explicit.
- Verification: Re-read all coordination files and confirm every required outcome maps to at least one task.
- Blocker/restart condition: none

## Task template

Copy this section for each new task, assign the next stable ID, then remove this
instructional sentence when the task graph is established.

### TASK-NNN — Outcome-oriented title

- Status: backlog
- Depends on: TASK-NNN or none
- Owner/session: unassigned
- Started/updated: TBD (timestamp with timezone)
- Responsibility: TBD
- Files or systems: TBD
- Worktree/branch: TBD
- Done when: TBD
- Verification: TBD
- Blocker/restart condition: none
