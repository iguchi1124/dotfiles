---
name: coordinator
description: Coordinate multi-task or multi-agent projects through durable, cross-tool specifications, task dependencies, ownership, decisions, and progress records. Use when parallel or long-running work needs shared state across Codex, Claude Code, agents, or sessions to prevent overlap and rework. Do not use for a single bounded implementation or merely because several files change.
---

# Coordinator

Coordinate the work; do not replace project implementation with process. Questions
about this skill and requests to edit its instructions are not workflow invocations.

## Boundary with orchestrator

- Use `coordinator` to maintain the shared project specification, task graph,
  assignments, dependencies, decisions, and handoffs across subagents or sessions.
- Use `orchestrator` for a bounded implementation task that needs its sequential Plan,
  Generate, Evaluate, Review, and Report stages.
- A coordinator task may use `orchestrator` when that task independently meets its
  trigger. Record the orchestrator task-directory path in the coordinator task and
  progress log; do not duplicate its internal stage state.

## Durable project directory

For a new project, run this skill's initializer at the active project or worktree root:

```bash
python3 <skill-directory>/scripts/init_project.py \
  --slug <short-kebab-case-slug> \
  --name '<project name>' \
  --request-file <file-containing-the-user-request>
```

The initializer creates `.coordinator/<YYYYMMDD>-<slug>/` atomically. This path is
shared with the Codex version of the skill. Omit
`--request-file` only when the exact request will be inserted into `project.md`
immediately afterward. `--root` may select another active worktree. Never overwrite,
delete, or recreate an existing project directory without explicit authorization.

Before creating a directory, search `.coordinator/` for the same project. Resume the
existing directory when the requested work is a continuation, even across tools,
subagents, or conversations. Runs created by an older skill version under
`.codex/coordinator/` or `.claude/coordinator/` remain resumable in place; do not copy,
move, or merge them without explicit authorization.

| File | Source of truth for |
| --- | --- |
| `project.md` | original request, goal, scope, constraints, and completion criteria |
| `spec.md` | current requirements, interfaces, invariants, acceptance criteria, and open questions |
| `tasks.md` | task status, dependencies, ownership, scope, work location, and verification |
| `progress.md` | append-only results, verification, handoffs, and blockers |
| `decisions.md` | accepted, rejected, and superseded decisions with rationale |
| `retro.md` | workflow friction, repeated patterns, and candidate instruction improvements |
| `initial-status.txt` | version-control status before the coordination directory was created |

Keep `spec.md` current rather than adding change history. Record why it changed in
`decisions.md` when the reason will matter later. Follow repository policy for
tracking `.coordinator/`; when unspecified, leave `.coordinator/` untracked.

## Establish the project

Before implementation or delegation:

1. Preserve the user's request verbatim in `project.md`, plus resolved assumptions and
   constraints. Persist conversation-only inputs or protected-source summaries that
   later subagents need; do not rely on conversation history.
2. Consolidate the current behavior and cross-component contracts in `spec.md`.
   Resolve a missing decision with the user when it changes scope, architecture,
   external behavior, cost, or risk.
3. Decompose the work in `tasks.md`. Every task must have one outcome, explicit
   dependencies, an owner, a file or responsibility boundary, a worktree or branch,
   a done-when condition, and verification.
4. Mark a task `ready` only when every dependency is `done`. Tasks with overlapping
   files, schemas, environments, or responsibilities must not run in parallel unless
   their coordination boundary is written explicitly.

Use only these task states: `backlog`, `ready`, `active`, `blocked`, `review`, and
`done`. `blocked` and `review` retain ownership. Never infer abandonment from elapsed
time or reassign owned work without a recorded handoff.

## Coordinate execution

The parent coordinator is the only writer to the coordination directory. Delegated
subagents read `project.md`, `spec.md`, `tasks.md`, and `decisions.md`, edit only their
assigned implementation scope, and return a report. They must not edit coordination
files. This keeps concurrent updates serial and prevents task-state merge conflicts.
Only one parent coordinator session may be active for a project across Codex and
Claude Code. Before switching tools or sessions, append a handoff to `progress.md`;
the receiving coordinator must re-read every coordination file before updating state.

Before delegating a task:

1. Re-read `spec.md`, `tasks.md`, and the latest `progress.md` entries.
2. Confirm dependencies are `done` and the scope does not overlap another active task.
3. Record the task as `active` with subagent or session identifier, responsibility and
   files, worktree and branch, start time with timezone, and verification command.
4. Put the absolute coordination-directory path and task ID in the subagent prompt.
   Require the subagent to report changed files, verification results, remaining work,
   and blockers.

Use parallel subagents only for independent `ready` tasks and only when delegation is
available and authorized. Use separate worktrees when subagents cannot safely edit
the same checkout. Do not create parallel work merely to keep subagents busy.

Treat subagent reports as claims. Inspect the resulting state and verification
evidence before marking a task `review` or `done`. Append the outcome to
`progress.md`, then update `tasks.md` and any affected `spec.md` or `decisions.md`.
Re-read the coordination files before every user status report.

## Limits and stop conditions

- Run at most three waves of newly delegated tasks in one invocation, then report a
  checkpoint before continuing in a later invocation.
- After two failed attempts for the same task, mark it `blocked` with the failure,
  restart condition, and required decision instead of retrying automatically.
- Every wait for a subagent or external state must have a timeout of at most ten
  minutes. On timeout, continue independent work or record the wait state; do not
  treat silence as task completion or abandonment.
- Stop when all required tasks are verified `done`, a user decision is required, no
  dependency-ready task remains, the wave cap is reached, or the user asks to stop.

Local coordination does not authorize commits, pushes, pull requests, issue creation,
deployments, or other external mutations. Obtain the authorization required by the
active workflow before performing them.

## Complete and report

Before declaring the project complete, verify that required tasks are `done`, their
done-when conditions have evidence, `spec.md` matches the delivered behavior, and all
open questions, skipped work, and residual risks are explicit.

Review the run for instruction friction before reporting. Record concrete friction,
repeated patterns, or a confirmed instruction defect in `retro.md`; do not invent a
finding when none occurred. Promote a lesson into the skill only after it recurs,
except for an obvious and reproducibly confirmed defect. Apply only behavior-preserving
clarifications without approval, and ask before changing loop caps, safety rules, or
stage structure. Keep machine-local learning state out of the repository.

Report the outcome and the absolute coordination-directory path so the paper trail is
discoverable.
