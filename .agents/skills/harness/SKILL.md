---
name: harness
description: Run an implementation task through the planner, generator, evaluator, reviewer, and reporter custom agents with durable state under .codex/harness. Use for a requested full loop, a feature or fix needing an independent check, or vague multi-file work. Do not use for a clear one-file edit.
---

# Harness

Drive the task through specialized custom agents. Delegate each stage and make only orchestration decisions; do not plan, implement, review, or report inline.

The `planner`, `generator`, `evaluator`, `reviewer`, and `reporter` custom agents are installed by `$codex-setup`. If a required agent is unavailable, stop and direct the user to that skill instead of replacing the missing role yourself.

## Choose the workflow size

| Task | Workflow |
| --- | --- |
| Clear one-file fix, typo, or exact copy of an existing pattern | No harness; handle directly or use one generator |
| Well-specified medium implementation | Mini loop; start at Generate |
| Vague specification, several files or repositories, long-running work | Full loop; start at Plan |

When uncertain, begin with the mini loop and promote to the full loop only if the generator cannot resolve the specification.

## Durable task directory

Create `.codex/harness/<YYYYMMDD>-<slug>/` at the project root for every run. Use today's date and a short kebab-case slug. Store state in files so compaction or agent turnover does not lose it.

| File | Contents |
| --- | --- |
| `spec.md` | concise user request and stated constraints |
| `initial-status.txt` | `git status --porcelain` before any stage |
| `plan.md` | planner output and later fix plans |
| `progress.md` | generator reports, one labeled section per round |
| `eval-<n>.md` | evaluator verdicts, never overwritten |
| `review-<n>.md` | reviewer triage, never overwritten. A project reviewer definition that names the file itself (e.g. `coderabbit-<n>.md`) wins |
| `retro.md` | instruction friction observed during the run |

Write `spec.md` even for a mini loop. Save every custom agent's return value verbatim before moving to the next stage. Follow repository policy for task-directory tracking; when unspecified, leave `.codex/harness/` untracked.

Ground rules:

- Spawn a fresh custom agent for every stage and retry; do not resume a prior agent thread.
- Run stages sequentially because each consumes the preceding artifact.
- Put the absolute task-directory path in every agent prompt.
- Treat agent reports as claims until the responsible verification stage confirms them.
- Send the user a brief status at each stage transition.
- Do not commit before Report, except the pre-Review commit in stage 4. Reporter may commit only in explicitly authorized pull-request mode.

## 1. Plan (full loop only)

Spawn `planner` with the user's request verbatim, the task-directory path, and all stated constraints. Save its output to `plan.md`.

The plan must contain a Review policy with fix/skip criteria. If it does not, ask the same fresh role for the missing section before continuing.

Show the user the Goal, step headings, and open questions. Resolve an assumption that would materially change implementation before Generate; ask the user when local evidence cannot safely decide it. Re-run planner for structural changes, or update a small assumption in `spec.md`.

## 2. Generate

Spawn a fresh `generator`. Tell it to read `spec.md`, `plan.md` when present, `progress.md`, and every `eval-*.md`. On retry rounds, fixing the latest evaluator blockers takes priority. Include any known environment constraints. Append the report to `progress.md` with the round number.

Stop for user direction if generator requires a new dependency or refuses a plan step. Complete independent safe work first when possible.

## 3. Evaluate

Spawn a fresh `evaluator` with the task-directory path and the next evaluation number. Describe generator's report explicitly as an implementer's claim and require independent verification. Save the output to a new `eval-<n>.md`.

- **PASS** — continue to Review. Keep non-blockers for Report.
- **FAIL** — return to Generate with a fresh agent.

Allow at most three FAIL rounds. Stop earlier when the same blocker returns unfixed twice; the plan or task then needs user input rather than another identical attempt.

## 4. Review

After evaluator passes, if the repository's reviewer only reads committed diffs (CodeRabbit's `-t committed`, for instance), commit the working tree to a task branch first (`git switch -c`, never a push); spawning it against an uncommitted tree only yields NOT-RUN. Then spawn a fresh `reviewer` with the task-directory path and next review number. It must run only the repository's adopted external review tool and triage findings using the plan's Review policy. Save output to `review-<n>.md` (or the project's name for it).

- **NO-REVIEWER / NOT-RUN** — record the reason and continue to Report.
- **CLEAN** — continue to Report.
- **FINDINGS** — retain `skip` items as design decisions; send `fix` items to a fresh generator, then evaluate and review again.

Do not re-plan ordinary fix findings. If reviewer includes `Plan impact`, verify the conflict against `plan.md`, then spawn planner and append a fix plan before Generate.

Allow at most two review rounds. After the cap, move remaining fix findings to design decisions labeled `loop cap reached` for the user to decide.

## 5. Report

Spawn a fresh `reporter` with the task-directory path, accumulated non-blockers, and the authorized mode:

- `report` unless the user explicitly requested a remote artifact
- `pull-request` or `issue` only when explicitly requested

Relay reporter's deliverable and include the task-directory path so the paper trail is discoverable.

## 6. Retrospect

After the report, inspect `retro.md`. Record friction when it occurs during the run; do not invent retrospective findings for a clean run. Only instruction defects in this skill qualify, not task-specific code, flaky tests, or agent judgment.

- A behavior-preserving clarification may be folded into `~/.dotfiles/.agents/skills/harness/SKILL.md`, leaving the edit uncommitted and reporting it to the user.
- Propose semantic changes to safety rules, caps, or stage structure before applying them.
- Record a one-off lesson without promotion. Promote recurring lessons after the same issue is observed twice; an obvious reproducible instruction defect may be corrected immediately.
- Rewrite the relevant existing passage; do not append duplicate rules.

## Gotchas

- Continue follow-up work on the same feature in its existing task directory; use a new directory for a different feature.
- Create an isolated `git worktree` (under the scratchpad) when the main worktree contains unrelated in-progress work, or before any stage that holds the tree for minutes (the external review, a full test run) - the user keeps using the main tree while the harness runs, and a checkout mid-review aborts it. Before `git worktree add`, make sure the project root has a `.worktreeinclude` (`.gitignore` syntax) naming every gitignored file the stages need - `.env`-style secrets, tool-local config; find candidates with `git status --ignored --porcelain`, never caches or build output. Write it, or add the missing lines, leave it untracked, and copy the listed files into the new worktree yourself: git does not read the file, but Claude Code does, so one list serves both harnesses. Record the worktree's absolute path and require every stage to operate there.
- At every transition, ensure the facts needed for the next decision are stored in task files, not only in conversation context.
