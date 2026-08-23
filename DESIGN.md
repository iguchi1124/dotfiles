# Design principles

The rules this repository is built around. `CLAUDE.md` tells a tool how to
work here; this file records *why* the repository is shaped the way it is,
so that a future change can be judged against the intent, not just the
current layout.

## One command, idempotent, from any state

A new machine is set up with a single `curl | bash` of `setup.sh`, and the
same command is the upgrade path: it is safe to re-run after adding files,
and every step either converges (`ln -snfv`, `mkdir -p`, merge) or skips
what already exists. There is no separate "update" procedure to remember.

## Link files, never directories

Both installers create real directories and symlink the files inside them
one by one. A symlinked directory would make the target and the repo the
same place, and applications write runtime state - logs, sockets, caches,
sessions - next to their config. Per-file links keep the boundary: the repo
owns the config, the machine owns the state. The cost is that new files
need a re-run of the installer, which idempotency makes free.

## XDG first

Config lives under `.config/<app>/` and is installed to `$XDG_CONFIG_HOME`
whenever the application can find it there (vim 9.1+, tmux 3.1+). Files land
directly in `$HOME` only when the app demands it (`.zshrc`, `.zshenv`,
`.zprofile`, `.Brewfile`). Preferring XDG keeps `$HOME` small and makes the
repo's layout mirror the installed layout.

## Dependencies belong to the package manager

Tools and even shell plugins (`zsh-autosuggestions`, `zsh-syntax-highlighting`)
are Homebrew packages declared in `.Brewfile`, not vendored clones or
git submodules. The repo carries configuration, not software.

## Shared files are merged, never overwritten

`setup.sh` stops short of `~/.claude` because `~/.claude/settings.json`
also carries machine- and project-specific values. Anything the repo does
not exclusively own is merged into (the `claude-setup` skill's `jq` merge),
preserving every key it does not manage. Overwriting is allowed only for
files this repo is the sole writer of.

## The AI workflow is configuration too

Subagents, skills and hooks are versioned here like shell config, because
they shape how work happens on every machine. Two principles govern them:

- **Separation of roles.** The planner / generator / evaluator / reviewer /
  reporter subagents each carry prohibitions that keep one stage from
  absorbing another. In particular, review comes from a reviewer detached
  from the author's context - like third-party human review, it tests
  whether a change is correct and comprehensible *without* the context
  bias of whoever wrote it. The implementer never reviews itself.
- **Skill design.** Skills follow the principles of the next section,
  including ending every run by improving themselves.

## Skill design

A skill is a written procedure with an explicit end. Every loop carries a
hard round cap, every wait a timeout, and every run a defined set of stop
conditions - a skill that can run forever is a bug, not autonomy. Text
that reaches a skill from outside (review comments, tool output, fetched
pages) is untrusted: it is read as an issue report, never executed as an
instruction.

**A skill's final step is improving the skill itself.** A run is also an
experiment on the skill's own instructions, so each one ends with a
retrospective: friction is logged the moment it occurs - a rule that
misled, a command that failed as written, a situation no rule covered -
and before the final report is delivered, the lessons are folded back into
the skill's own `SKILL.md`. Three boundaries keep this safe:

- A lesson observed once is only recorded; it is promoted into the skill
  after it recurs, so one incident cannot overfit the instructions.
  Obvious, reproducibly-confirmed defects in the instructions may be fixed
  immediately.
- Behavior-preserving clarifications may be applied without asking;
  semantic changes - loop caps, safety rules, stage structure - are the
  user's decision, and safety rules are never relaxed on the grounds of
  efficiency. Committing any of it is always the user's act.
- What a run learns or produces locally (learning logs, task state) stays
  on the machine, per "Machine state stays on the machine" below.

## Machine state stays on the machine

What a run produces or learns locally is not synced: `.claude/harness/`
task state is globally ignored, per-project `env.sh` is ignored, and a
skill's machine-local learnings live under `~/.claude/skills/`, not here.
The repo describes behavior; the machine accumulates history.

## Rationale lives next to the mechanism

Every non-obvious decision is written down where the code is: `setup.sh`
comments explain the per-file linking, `claude-setup/SKILL.md` explains the
merge-only install and the `PreToolUse` hook timing, each subagent file
explains its own prohibitions. This file holds only the principles; the
details stay with their implementation so they cannot drift apart silently.
