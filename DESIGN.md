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
- **Self-improvement with a boundary.** Skills observe their own runs and
  fold the lessons back into their instructions. Behavior-preserving
  clarifications may be applied automatically; semantic changes - loop
  caps, safety rules, stage structure - need the user, and committing the
  result is always the user's act. Safety rules are never relaxed on the
  grounds of efficiency.

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
