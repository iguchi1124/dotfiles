---
title: {{PROJECT_TASKS_TITLE_YAML}}
status: In progress
scope: "Task breakdown, priority, dependencies, research results, and progress"
---

# {{PROJECT_NAME}} Implementation Tasks

Use P0 for critical-path work, P1 for work required in the initial release, and P2 for
work that can follow the release. Estimate size as S (one day or less), M (two or three
days), or L (one week or more).

## 0. Prerequisite research

| ID | Task | Priority | Size | Depends on | Status |
|---|---|---|---|---|---|
| PRE-1 | TBD (verify facts needed for specification decisions) | P0 | S | — | Not started |

## 1. Specification and preparation

| ID | Task | Priority | Size | Depends on | Status |
|---|---|---|---|---|---|
| SPEC-1 | TBD (finalize requirements and acceptance criteria) | P0 | M | PRE-1 | Not started |

{{COMPONENT_TASK_SECTIONS}}

## {{RELEASE_SECTION_NUMBER}}. Cross-component validation and release

| ID | Task | Priority | Size | Depends on | Status |
|---|---|---|---|---|---|
| QA-1 | TBD (integration and acceptance testing) | P0 | M | SPEC-1 | Not started |
| REL-1 | TBD (release and monitoring) | P0 | S | QA-1 | Not started |

## Risks

| Risk | Impact | Mitigation |
|---|---|---|
| TBD | TBD | TBD |
