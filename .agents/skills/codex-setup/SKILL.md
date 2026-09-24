---
name: codex-setup
description: Install, repair, or verify this dotfiles repository's Codex configuration. Copies the global AGENTS.md, custom agents and personal skills into their user locations, overwriting installed files, and initializes config.toml from a template only when absent. Use on a new machine or after adding, removing, renaming, or changing Codex configuration in this repository.
---

# Codex Setup

`setup.sh` installs shell and application configuration but deliberately leaves Codex's user-owned directories alone. This skill installs the Codex layer without replacing shared configuration files.

## Managed sources and targets

| Repository source | User target | Behavior |
| --- | --- | --- |
| `.codex/config.toml.template` | `${CODEX_HOME:-$HOME/.codex}/config.toml` | copied only when absent; existing files and symlinks are left unchanged |
| `.codex/AGENTS.md` | `${CODEX_HOME:-$HOME/.codex}/AGENTS.md` | copied as the global instruction file |
| `.codex/agents/*.toml` | `${CODEX_HOME:-$HOME/.codex}/agents/` | copied file by file |
| `.agents/skills/<name>/` | `$HOME/.agents/skills/<name>/` | copied file by file; `codex-setup` and `claude-setup` are skipped; both remain repository-scoped. All skill sources live here, and `.claude/skills` is a symlink to this directory that `claude-setup` follows |

Targets are real directories containing independent file copies. Installed instructions, custom agents, and skills are overwritten from dotfiles; legacy file symlinks are removed before copying so their referents are not modified. Symlinked destination directories are refused. Files absent from the source, including machine-local learning logs, are preserved.

## Install

Run:

```sh
sh "$HOME/.dotfiles/.agents/skills/codex-setup/scripts/install.sh"
```

Report the script's output. The operation is idempotent. Re-run it after changing dotfiles to refresh installed copies, then use `cmp` to compare each changed source refreshed by the installer with its installed file. Compare `.codex/config.toml.template` with `config.toml` only when this run created the previously absent destination; existing configuration files and symlinks are preserved and need not match the template. Report refreshed changes as reflected only after installation and every applicable comparison succeed; otherwise report the source update and the refresh failure separately. Machine-local learning logs remain local.

After a source removal or rename, the installer leaves the old target in place. List the target `agents` and skill directories, then remove only confirmed repository-owned stale files or links: compare copies with the prior source or a pre-change hash, and resolve symlink targets to the removed repository source. Recheck that identity immediately before removal; preserve and report mismatches. Never delete machine-local files such as `learnings.md` or whole directories containing them.

## What is installed

### Initial config.toml

The installer copies `.codex/config.toml.template` only when
`${CODEX_HOME:-$HOME/.codex}/config.toml` is absent. Existing files and symlinks,
including broken symlinks, are left unchanged. Re-running setup or editing the
template does not merge or update installed configuration.

The template supplies the initial approval reviewer.
Machine-specific paths, project trust, authentication, and application state belong
in the installed environment. After initialization, edit the installed `config.toml`
to change preferences.

### Global AGENTS.md

`${CODEX_HOME:-$HOME/.codex}/AGENTS.md` loads personal GitHub-writing rules in every repository. Project-level `AGENTS.md` files add repository-specific guidance and closer files take precedence.

### Custom agents

Three custom agents handle the first stages:

- `planner` — returns a grounded, verifiable plan without editing
- `generator` — implements the assigned plan or verified finding; pinned to `gpt-6-sol`, one model tier below the orchestrator, since a plan bounds its work and it is the stage that reads and runs the most
- `evaluator` — independently checks the result and returns PASS or FAIL

planner uses `gpt-6-astra` with `high` reasoning effort. generator uses `medium` reasoning effort. evaluator uses `gpt-6-astra` with `high` reasoning effort as well: it is the PASS/FAIL gate on generator's work and must not be weaker than what it checks.

Custom definitions preserve the boundaries between planning, generation, and evaluation; read the complete contract before reducing or moving an instruction.

### Skills

- `$orchestrator` executes one task through isolated Plan, Generate, and Evaluate
  contexts in a dedicated worktree, retaining one `task.md`. It reuses the task's
  generator for fixes and starts fresh evaluators; it does not manage `tasks.md`.
- `$coordinator` lets the conversation parent create and maintain shared `spec.md`
  and `tasks.md`, prepare task IDs and worktree assignments for explicit execution,
  and track overall progress. It does not launch orchestrator. All worktrees use
  one canonical directory per project. Dependency changes must be available before
  a task starts.
- `$codex-setup` and `$claude-setup` remain repository-scoped so they do not appear in unrelated projects.

The first two are one source each, shared with Claude Code through the
`.claude/skills` directory symlink; where the tools differ, the source names both
variants.

## Verify

Restart Codex after installation, then confirm:

1. Repository-managed custom agents are `planner`, `generator`, and `evaluator`; confirmed stale `reviewer` and `reporter` definitions are absent.
2. Skill selection includes `orchestrator` and `coordinator`.
3. A newly created `config.toml` matches the template; an existing configuration remains unchanged.
