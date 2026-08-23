---
name: harness
description: Runs a task through the planner → generator → evaluator → reviewer → reporter subagent loop, passing state through files in .claude/harness/<task-dir>/ so long tasks survive context compaction. Use for "run the harness" / "run the full loop", for a feature or fix worth an independent check, or for vague requests that span several files. Not for a clear one-file fix.
---

# harness

Drive the task through the five subagents in order. You are the orchestrator:
you delegate, relay, and decide. While the harness runs you never plan, code,
review, or report the work yourself - each of those belongs to its subagent,
and doing it inline defeats the separation the subagents exist for.

The `planner`, `generator`, `evaluator`, `reviewer` and `reporter` subagents
are installed from this dotfiles repo (`.claude/agents/`, via the
`claude-setup` skill). If any of them is missing from the available agent
types, stop and point the user at that skill instead of improvising the stage
inline.

## 0. Gauge the task first

The loop pays for itself only when the task strains a single context. Pick
the smallest shape that fits:

| Task | Shape |
| --- | --- |
| Clear one-file fix, typo, copy of an existing pattern | **No harness** - one generator, or just do it |
| Well-specified, medium-sized implementation | **Mini loop** - skip planner, start at Generate |
| Vague spec, several files or repos, long-running | **Full loop** - start at Plan |

When unsure, start with the mini loop; if generator reports it cannot pin the
spec down, promote to the full loop from there.

## Task directory

Every run - mini or full - gets `.claude/harness/<YYYYMMDD>-<slug>/` at the
project root (today's date, kebab-case slug). State lives in these files, not
in the conversation: if the context is compacted mid-task, re-read the
task-dir and continue.

| File | Written by | Holds |
| --- | --- | --- |
| `spec.md` | you, at the start | the user's request verbatim, plus stated constraints |
| `initial-status.txt` | you, at the start | `git status --porcelain` before any stage runs - reporter's staging baseline |
| `plan.md` | you, from planner's output | the plan, verbatim; fix plans appended below it |
| `progress.md` | you, from generator's reports | one appended section per round |
| `eval-<n>.md` | you, from evaluator's output | one verdict per file, numbered by existing files |
| `review-<n>.md` | you, from reviewer's output | one triage per file, same numbering rule |
| `retro.md` | you, as friction occurs | notes on where this skill's own instructions failed you - input for Retrospect |

Write `spec.md` yourself even in the mini loop - 2-5 lines summarizing the
request - so generator's input never depends on the conversation. Save each
agent's returned artifact to its file verbatim before moving on. Follow the
project's own practice on whether `.claude/harness/` is committed; when in
doubt leave it untracked.

Ground rules for every stage:

- **Spawn every agent fresh.** No SendMessage resumes, including retries after
  a FAIL - the previous state is in `progress.md` / `eval-<n>.md`, so put the
  task-dir's absolute path in every prompt and let the agent read it.
- Never run stages in parallel - each depends on the previous artifact.
- Take no agent's report on faith. Generator's "tests pass" is a claim until
  evaluator's verdict, and is reported to the user as unconfirmed until then.
- Post a one-line status to the user at each stage transition.
- Nothing before the report stage commits. Git stays untouched until
  reporter, and reporter only writes in `pull-request` mode.

## 1. Plan (full loop only)

Spawn `planner` with the user's request verbatim (no rewording), the
task-dir path, and any constraints already stated in the conversation. Save
the returned plan to `plan.md`. The plan carries a **Review policy** - the
fix/skip criteria reviewer will later triage external findings by; if it is
missing, have planner add it before moving on.

Show the user the plan's Goal, Step headings, and Open questions - a few
lines, not the whole plan. If an Open question's assumption would change the
implementation, resolve it with AskUserQuestion **before** Generate and fold
the answer into `spec.md` (re-run planner for anything structural; edit the
assumption note yourself for a small one). Never hand generator a plan with
a live fork in it.

## 2. Generate

Spawn a fresh `generator`. The prompt names: the task-dir path and that it
must read `spec.md`, `plan.md` (if present), `progress.md` and every
`eval-*.md`; on retry rounds, that fixing the latest `eval-<n>.md` blockers
comes first; and any environment traps you already know (how tests actually
run here, required wrappers). Append its report to `progress.md`.

Two of its reports need you to stop and ask the user before continuing:
a dependency it wants to add, or a plan step it refused. Those decisions are
the user's, not yours.

## 3. Evaluate

Spawn a fresh `evaluator` with the task-dir path and the round number n
(count the existing `eval-*.md` - never overwrite one, that erases the FAIL
history). Summarize generator's report in the prompt but label it as the
implementer's claim, not evidence, and tell it to run the verification
itself - never phrase it as "confirm generator's report", which invites a
rubber stamp. Save the verdict to `eval-<n>.md`.

- **PASS** - continue to Review. Non-blocker findings go to reporter, not
  back into the loop.
- **FAIL** - back to Generate. At most three FAIL rounds, and stop earlier
  if the same finding comes back unfixed twice - that means the plan or the
  task needs the user, not another round.

## 4. Review

Spawn a fresh `reviewer` with the task-dir path and the report number (same
numbering rule, over `review-*.md`). It runs the external review tool the
project has adopted (CodeRabbit, Copilot, ...) and triages each finding into
`fix` or `skip` **by the plan's Review policy** (in the mini loop, with no
plan, it falls back to `spec.md` and the repo's conventions); it never
reviews by itself. Save the triage to `review-<n>.md`.

- **NO-REVIEWER / NOT-RUN** - nothing adopted, or nothing runnable. Note the
  reason for reporter and continue to Report.
- **CLEAN** - continue to Report.
- **FINDINGS** - split by disposition:
  - `skip` findings accumulate for reporter as design decisions, with
    reviewer's why attached. Skipping is legitimate - a finding not worth
    acting on, or blocked on the user's judgment, is recorded, not fixed.
  - `fix` findings go straight back to **Generate** - the plan's Review
    policy already decided their handling, so no new planning round. The
    fresh generator's prompt names `review-<n>.md` and that fixing its `fix`
    findings is the goal. Then Evaluate as usual - the fixes must PASS,
    including no regression on the plan's original done-when conditions -
    and Review again.

So the loop on findings is reviewer → generator → evaluator (PASS) →
reviewer. The exception is a `fix` finding that invalidates the plan itself:
reviewer flags one with a `Plan impact` line in its triage, and you confirm
the conflict against `plan.md` yourself - the re-plan call is yours, never
reviewer's. For those, spawn `planner` with the finding and the task-dir,
append the returned fix plan to `plan.md`, and only then Generate. Ordinary
`fix` findings - no plan impact - never wait on a planning round.

At most two review rounds. Whatever `fix` findings remain after the second
round are demoted to design decisions ("loop cap reached") and the harness
moves on - the user decides their fate from the report.

## 5. Report

Spawn a fresh `reporter` with the task-dir path - it reads `spec.md`,
`plan.md`, `progress.md`, `eval-*.md` and `review-*.md` itself - plus the
non-blocker findings and the mode:

- **report** unless the user asked for something else - reporter writes the
  user-facing summary, including the design decisions for the user to
  overrule.
- **pull-request** or **issue** only when the user asked for one in the
  conversation. Never order a Pull Request or an issue on your own.

Relay reporter's deliverable to the user as the harness's final message, add
the task-dir path so the paper trail is findable, and nothing else beyond a
closing status line - except a Retrospect note (stage 6), the one thing
allowed to follow it.

## 6. Retrospect - improve this skill

After the report is delivered, read `retro.md` and decide whether this run
exposed a defect in **this skill's own instructions** - not in the task, the
code, or an agent's judgment. Throughout the run, whenever the skill fails
you, append one line to `retro.md` at that moment (waiting until the end
loses them): an instruction an agent repeatedly misread, guidance you had to
improvise because no rule covered the situation, a stage transition that
needed off-script clarification, a new gotcha worth the Gotchas list.

Task-specific friction (flaky tests, odd repo layout) stays in the task-dir;
only lessons that would change how the *next* run behaves qualify.

If `retro.md` is missing or empty (a friction-free run never creates it) or
nothing qualifies, skip silently - no forced findings. Otherwise:

- Edit the source file `~/.dotfiles/.claude/skills/harness/SKILL.md` directly
  for **behavior-preserving** edits only: wording fixes, missing gotchas,
  and clarified rules that change how the text reads, not what the harness
  does. The skill is symlinked into `~/.claude`, so the edit takes effect
  next run. This edit targets the skill's canonical source, not the task's
  code, so it is the one deliberate exception to the worktree rule in
  Gotchas - never route it through a task worktree. Leave the change
  uncommitted and summarize it to the user after the harness's final
  message - the commit is theirs.
- A **semantic** change - anything that alters behavior: adding/removing a
  stage, changing loop caps, agent responsibilities, worktree handling, or
  any safety rule - or any edit to a subagent under
  `~/.dotfiles/.claude/agents/` is proposed to the user first with the
  exact diff, never applied on your own. When unsure which kind an edit is,
  treat it as semantic. Read the `claude-setup` skill before touching
  anything under `.claude/`, per the repo's CLAUDE.md.

## Gotchas

- **One task-dir per feature.** A follow-up sprint on the same feature
  continues in the same task-dir; a different feature gets a new one.
- If the main working tree has another branch's work in progress, isolate
  the task in a `git worktree` (under the scratchpad). Record the worktree's
  absolute path in `spec.md`, put it in every agent prompt alongside the
  task-dir, and require every stage - file edits, git, the external review -
  to run inside that worktree, never the main tree.
- At each stage transition, check that the facts your decisions rest on are
  in the task-dir files, not only in the conversation - add what is missing.
