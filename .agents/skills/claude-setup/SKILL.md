---
name: claude-setup
description: Install, repair, or verify this repo's Claude Code configuration. Copies CLAUDE.md, custom agents and global skills into ~/.claude, overwriting installed files, and initializes settings.json from a template only when absent. Use on a new machine or after adding, removing, renaming, or changing Claude Code configuration in this repo.
---

# claude-setup

`setup.sh` links the shell, vim and tmux config, and stops there. Everything under
`~/.claude` is installed by this skill instead, because one part of it -
`~/.claude/settings.json` - carries machine- and project-specific values. The
installer creates it from the template only when absent and leaves existing settings
unchanged.

All skill sources live in `.agents/skills/`; `.claude/skills` is a relative
symlink to that directory. Both installers keep the setup skills repository-scoped.
This installer works through either source path.

## What gets installed

| Source in this repo | Target | Notes |
| --- | --- | --- |
| `.claude/CLAUDE.md` | `~/.claude/CLAUDE.md` | Copied as the global instruction file, loaded in every session. |
| `.claude/agents/*` | `~/.claude/agents/` | Copied file by file. |
| `.claude/skills/*` | `~/.claude/skills/<name>/` | Copied file by file, including nested files. The source directory is a symlink to `.agents/skills/`; installed skills are real directories of copies (`agents/openai.yaml` comes along and is ignored by Claude Code). Both `claude-setup` and `codex-setup` are skipped - they stay project skills of this repo. |
| `.claude/settings.json.template` | `~/.claude/settings.json` | Copied only when absent; existing files and symlinks are left unchanged. |

Targets are real directories containing independent file copies. Installed
instructions, custom agents, and skills are overwritten from dotfiles;
legacy file symlinks are replaced only after a copy is prepared, leaving their
referents unchanged and preserving the links if copying fails.
Symlinked destination directories, including a legacy `~/.claude/skills` link,
are refused. Files absent from the source, including machine-local learning logs,
are preserved.

## 1. Copy the files

Idempotent, and safe to re-run after adding an agent or a skill:

```sh
sh "$HOME/.dotfiles/.agents/skills/claude-setup/install.sh"
```

Report what it printed. Re-run it after changing dotfiles to refresh installed
copies, then use `cmp` to compare each changed source refreshed by the installer
with its installed file. Compare `.claude/settings.json.template` with
`settings.json` only when this run created the previously absent destination;
existing settings files and symlinks are preserved and need not match the template.
Report refreshed changes as reflected only after installation and every applicable
comparison succeed; otherwise report the source update and the refresh failure
separately. Machine-local learning logs remain local.

A source removal or rename leaves the old target behind.
List the affected installed directories; remove only
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
`reviewer` and `reporter` definitions are absent, and `orchestrator` and `coordinator`
are available.
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
  pinned to `claude-opus-5-5`, one tier below the conversation's model: with a plan in
  hand its work is bounded, and it is the stage that reads and runs the most
- **evaluator** - checks the result and returns PASS/FAIL with reproducible findings

planner uses `claude-fable-5-1` with `high` effort. generator uses `medium` effort.
evaluator uses `claude-fable-5-1` with `high` effort as well: it is the PASS/FAIL gate on generator's work and must not be weaker than what it checks.

Custom definitions preserve the boundaries between planning, generation, and
evaluation; read the complete contract before reducing or moving an instruction.

### orchestrator

The skill that executes one task through isolated Plan, Generate, and Evaluate
contexts, reusing its generator for fixes and starting fresh evaluators. Each task
uses a dedicated worktree and one `.orchestrator/<task-dir>/task.md`. Shared
`tasks.md` and overall project progress belong to coordinator.
Installed globally so it is one `/orchestrator` away in any project.
Like `coordinator` below, the skill is one source
shared with Codex: `.agents/skills/orchestrator/`, exposed through the `.claude/skills` directory symlink.

### coordinator

The skill used by the conversation parent to create and maintain the shared task
board, prepare task IDs and worktree assignments for separate execution, and track
multi-task project progress. It does not launch orchestrator. Its
state lives in `spec.md` and `tasks.md` under one canonical
`.coordinator/<project-dir>/` in the primary checkout or supplied shared root.
All worktrees use that absolute path; a root-level writer lock covers project
selection and state updates. Dependency changes must be available before a task
starts. The skill itself is shared with Codex:
it lives in `.agents/skills/coordinator/`, exposed through the `.claude/skills`
directory symlink. `orchestrator` is shared the same way;
where the tools differ, the one source names both variants. Only `claude-setup` and
`codex-setup` are tool-specific. The user may invoke `orchestrator` separately with
a ready task ID.
