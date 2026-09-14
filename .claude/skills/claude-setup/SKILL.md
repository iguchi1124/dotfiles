---
name: claude-setup
description: Installs this repo's Claude Code configuration into ~/.claude - links CLAUDE.md, the planner/generator/evaluator/reviewer/reporter subagents and the global skills, then copies the settings.json template only if ~/.claude/settings.json does not exist. Use when setting up Claude Code on a new machine, after adding or renaming a subagent or a skill in this repo, or when asked to install, repair or verify the Claude Code setup.
---

# claude-setup

`setup.sh` links the shell, vim and tmux config, and stops there. Everything under
`~/.claude` is installed by this skill instead, because one part of it -
`~/.claude/settings.json` - carries machine- and project-specific values. The
installer creates it from the template only when absent and leaves existing settings
unchanged.

## What gets installed

| Source in this repo | Target | Notes |
| --- | --- | --- |
| `.claude/CLAUDE.md` | `~/.claude/CLAUDE.md` | Loaded in every session, whatever the working directory. |
| `.claude/agents/*` | `~/.claude/agents/` | Linked file by file, never as a directory. |
| `.claude/rules/*` | `~/.claude/rules/` | Linked file by file. Path-scoped rules (`paths:` frontmatter) load only when Claude touches matching files. |
| `.claude/skills/*` | `~/.claude/skills/<name>/` | File by file, one directory per skill. `claude-setup` itself is skipped - it stays a project skill of this repo. |
| `.claude/settings.json.template` | `~/.claude/settings.json` | Copied only when absent; existing files and symlinks are left unchanged. |

`~/.claude/skills` used to be a symlink to a separate skills repo; `install.sh` removes
that legacy symlink and replaces it with a real directory when it finds one.

Files are linked individually rather than linking the directory, for the same reason
as `.config/<app>/` in `setup.sh`: Claude Code writes runtime state (sessions, caches,
history) into these directories, and a symlinked directory would drop that state into
this repo.

## 1. Link the files

Idempotent, and safe to re-run after adding an agent or a skill:

```sh
sh "$HOME/.dotfiles/.claude/skills/claude-setup/install.sh"
```

Report what it printed. Re-running after a rename leaves the old link behind - list
`~/.claude/agents`, `~/.claude/rules` and `~/.claude/skills` and
remove any symlink (or skill directory) whose target no longer exists.

## 2. Initialize settings.json once

`install.sh` copies `.claude/settings.json.template` to `~/.claude/settings.json`
only when the destination is absent. Existing files and symlinks, including broken
symlinks, are left unchanged. Re-running setup or editing the template does not
update installed settings. This happens during setup, not on each application launch.

Edit the template to change defaults for new installations. It supplies the
permission mode, following the documented
[permission modes](https://code.claude.com/docs/en/permissions#permission-modes).
The `attribution.sessionUrl: false` default keeps private conversation links out of
commits and pull requests. Machine-specific paths, credentials, plugin state, and
individual permission rules are configured in the installed environment. After
installation, manage settings in `~/.claude/settings.json`.

## 3. Verify

Restart Claude Code after installation. Confirm that `planner`, `generator`,
`evaluator`, `reviewer`, and `reporter` are available agent types, and `harness` is an
available skill. A newly created `settings.json` should match the template; an
existing settings file should remain unchanged.

## What is installed

### Global CLAUDE.md

`~/.claude/CLAUDE.md` is read in every session regardless of the working directory.
Project level `CLAUDE.md` files are read in addition to it, and win where they conflict.

### Subagents

Available from any project, and built to chain - the planner's plan feeds the generator,
the evaluator's findings hand straight back to the generator, its PASS hands to the
reviewer, and the reporter packages the outcome:

- **planner** - breaks a task into verifiable steps; writes no code
- **generator** - implements a plan and gets lint and tests passing
- **evaluator** - checks the result and returns PASS/FAIL with reproducible findings
- **reviewer** - runs the project's adopted external review tool (CodeRabbit, Copilot,
  ...) and triages each finding into fix or skip; reviews nothing itself
- **reporter** - delivers the outcome as a report, or a GitHub Pull Request/issue when
  asked; the only one allowed to commit, and only in pull-request mode

Each one's prohibitions are what keep that separation intact, so read the whole file
before trimming one.

### harness

The skill that chains all five: plan, implement, check, external review, report -
looping evaluator findings back into generator, and reviewer findings back into
generator too, triaged by the Review policy the plan sets in advance - then delivering
the outcome as a report or a GitHub Pull Request/Issue. State passes
through files in the project's `.claude/harness/<task-dir>/`, so long tasks survive
context compaction and every agent is spawned fresh. Installed globally so it is one
`/harness` away in any project.
