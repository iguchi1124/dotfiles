---
name: claude-setup
description: Installs this repo's Claude Code configuration into ~/.claude - links CLAUDE.md, the planner/generator/evaluator subagents and the global skills, then copies the settings.json template only if ~/.claude/settings.json does not exist. Use when setting up Claude Code on a new machine, after adding, removing, renaming, or changing a subagent or a skill in this repo, or when asked to install, repair or verify the Claude Code setup.
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

Report what it printed. A source removal or rename leaves the old target behind.
List `~/.claude/agents`, `~/.claude/rules`, and `~/.claude/skills`; remove only
confirmed repository-owned stale files or links. Resolve symlink targets to the
removed repository source, or compare copies with the prior source or a pre-change
hash. Recheck that identity immediately before removal; preserve and report
mismatches. Never delete machine-local files such as `learnings.md` or whole
directories containing them.

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

Restart Claude Code after installation. Confirm that the repository-managed
custom agents are `planner`, `generator`, and `evaluator`, confirmed stale
`reviewer` and `reporter` definitions are absent, and `harness` is available.
Review and Report use the built-in `general-purpose` type.
A newly created `settings.json` should match the template; an
existing settings file should remain unchanged.

## What is installed

### Global CLAUDE.md

`~/.claude/CLAUDE.md` is read in every session regardless of the working directory.
Project level `CLAUDE.md` files are read in addition to it, and win where they conflict.

### Subagents

Three custom agents are available from any project:

- **planner** - breaks a task into verifiable steps; writes no code
- **generator** - implements a plan and gets lint and tests passing. It is
  pinned to `opus` at `high` effort, one tier below the conversation's model:
  with a plan in hand its work is bounded, and it is the stage that reads and
  runs the most
- **evaluator** - checks the result and returns PASS/FAIL with reproducible findings

planner and evaluator inherit the conversation's model and effort, so the
stages that shape the work and check it stay at least as capable as the one
that does it.

Review and Report use fresh built-in `general-purpose` agents: Review runs the
adopted external tool and triages its findings; Report packages the outcome and
performs only explicitly authorized publication. Their contracts live in the
calling skills. Custom definitions and explicit caller prompts preserve role
separation; read the complete contract before reducing or moving an instruction.

### harness

The skill that chains all five stages: plan, implement, check, external review, report -
looping evaluator findings back into generator, and reviewer findings back into
generator too, triaged by the Review policy the plan sets in advance - then delivering
the outcome as a report or a GitHub Pull Request/Issue. State passes
through files in the project's `.claude/harness/<task-dir>/`, so long tasks survive
context compaction and every agent is spawned fresh. Installed globally so it is one
`/harness` away in any project.
