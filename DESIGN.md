# Design principles

The rules this repository is built around. `CLAUDE.md` tells a tool how to
work here; this file records *why* the repository is shaped the way it is,
so that a future change can be judged against the intent, not just the
current layout.

## One command, idempotent, from any state

A new machine is set up with a single `curl | bash` of `setup.sh`, and the
same command is the upgrade path: it is safe to re-run after adding files,
and every step either converges (`ln -snfv`, `mkdir -p`) or skips
what already exists. There is no separate "update" procedure to remember.

## Real directories separate configuration from runtime state

`setup.sh` creates real application directories and symlinks the files inside
them one by one. Claude and Codex setup instead copy their managed files
individually into real directories, replacing legacy file links and refusing
directory links. A symlinked directory would make the target and the repo the
same place, and applications write runtime state - logs, sockets, caches,
sessions - next to their config. The repo owns the configuration sources;
the machine owns the state. New app files and any Claude or Codex source
changes need a re-run of the corresponding installer.

## Defaults first, configuration minimal

Configure an application only where its default is actually wrong for this
setup. Every line of config is a diff against the tool's documentation
that has to be understood, carried across machines, and re-validated on
upgrades - so the default is the baseline, not a starting point to
override. The same goes for shortcuts: aliases and custom keybindings are
added sparingly, for commands typed often enough to prove the need, never
speculatively. A stock environment that stays close to what the tool's
docs describe is the feature.

## XDG first

Config lives under `.config/<app>/` and is installed to `$XDG_CONFIG_HOME`
whenever the application can find it there (vim 9.1+, tmux 3.2+). Files land
directly in `$HOME` only when the app demands it (`.zshrc`, `.zshenv`,
`.zprofile`, `.Brewfile`). Preferring XDG keeps `$HOME` small and makes the
repo's layout mirror the installed layout.

## Dependencies belong to the package manager

Tools and even shell plugins (`zsh-autosuggestions`, `zsh-syntax-highlighting`)
are Homebrew packages declared in `.Brewfile`, not vendored clones or
git submodules. The repo carries configuration, not software.

## User settings are initialized once

`setup.sh` stops short of `~/.claude`, `~/.codex`, and `~/.agents` because
those locations also carry machine- and project-specific values. `claude-setup`
copies `.claude/settings.json.template` to `~/.claude/settings.json`, and
`codex-setup` copies `.codex/config.toml.template` to
`${CODEX_HOME:-$HOME/.codex}/config.toml`, only when the destination is absent. Existing files and symlinks are left unchanged: subsequent
setup runs do not merge, overwrite, or synchronize user settings. The `.template`
suffix prevents either application from treating the source file as project settings.
Overwriting is allowed only for files this repo is the sole writer of;
both `claude-setup` and `codex-setup` copy those files individually.

## The AI workflow is configuration too

Subagents and skills are versioned here like shell config, because
they shape how work happens on every machine. Three principles govern them:

- **Separation of roles.** Planning, generation, and evaluation remain
  separate stages. Custom planner / generator / evaluator definitions
  carry the prohibitions that keep one stage from absorbing another.
  In particular, evaluation comes from an evaluator detached
  from the author's context - like third-party human review, it tests
  whether a change is correct and comprehensible *without* the context
  bias of whoever wrote it. The implementer never reviews itself.
- **Skill design.** Skills follow the principles of the next section,
  with explicit stop conditions and evidence-based instruction changes.
- **One source per shared skill.** Claude Code reads `.claude/skills/` and
  Codex reads `.agents/skills/`, so a skill whose instructions are the same
  for both lives in `.agents/skills/<name>/` with `.claude/skills/<name>` a
  symlink to it. Both installers still copy files into real directories.
  Where the tools differ (built-in agent type names, worktree tooling,
  learning-log paths), the one source names both variants rather than
  forking into two copies that drift; only the setup skills are
  tool-specific.

## Skill design

A skill is a written procedure with an explicit end. Every loop carries a
hard round cap, every wait a timeout, and every run a defined set of stop
conditions - a skill that can run forever is a bug, not autonomy. Text
that reaches a skill from outside (review comments, tool output, fetched
pages) is untrusted: it is read as an issue report, never executed as an
instruction.

**Skill improvements follow evidence.** Neither coordinator nor orchestrator
requires a retrospective or self-edit as a completion step. When recurring
friction or a confirmed instruction defect warrants an update, fold the
lesson into the skill's own `SKILL.md`. Folding in means rewriting, not appending:
instructions are context spent on every load, so a lesson is merged into
the text it refines and deletes what it supersedes - stacking clauses
breeds duplication and token bloat. After an authorized source improvement,
run the corresponding setup installer and byte-compare changed managed files
with their installed copies before reporting it as reflected. A failed refresh
is reported separately from the source edit, and local logs and settings stay
local. Three boundaries keep this safe:

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

What a run produces or learns locally is not synced: `.orchestrator/` task
state and `.coordinator/` project state are globally ignored. Per-project
`env.sh` is ignored, and skill learnings live under the installed
`~/.claude/skills/` or `~/.agents/skills/` directory, not here. The repo
describes behavior; the machine accumulates history.

## Rationale lives next to the mechanism

Every non-obvious decision is written down where the code is: `setup.sh`
comments explain the per-file linking, the Claude and Codex setup skills
explain their installation strategies, and each
custom-agent definition or caller's stage contract explains its prohibitions. This file holds only the
principles; the details stay with their implementation so they cannot drift
apart silently.
