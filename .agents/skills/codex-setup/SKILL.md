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
| `.agents/skills/<name>/` | `$HOME/.agents/skills/<name>/` | copied file by file; `codex-setup` itself is skipped |

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
- `generator` — implements the assigned plan or verified finding; pinned to `gpt-5.6-sol`, one model tier below the orchestrator, since a plan bounds its work and it is the stage that reads and runs the most
- `evaluator` — independently checks the result and returns PASS or FAIL

planner uses `gpt-6-astra` with `high` reasoning effort. generator uses `medium` reasoning effort. evaluator inherits the session's model and reasoning effort.

Review and Report use fresh built-in `default` agents: Review runs only an adopted external tool and triages its findings; Report packages the outcome and performs only explicitly authorized publication. Their contracts live in the calling skills. Custom definitions and explicit caller prompts preserve role separation; read the complete contract before reducing or moving an instruction.

### Skills

- `$orchestrator` coordinates all five stages with durable project state.
- `$code-review-autofix` handles bounded review, fix, push, and re-review cycles.
- `$coordinator` manages durable specifications, task dependencies, ownership, decisions, and progress for parallel or long-running work.
- `$codex-setup` remains repository-scoped so it does not appear in unrelated projects.

## Verify

Restart Codex after installation, then confirm:

1. Repository-managed custom agents are `planner`, `generator`, and `evaluator`; confirmed stale `reviewer` and `reporter` definitions are absent. Review and Report use the built-in `default` type.
2. Skill selection includes `orchestrator`, `coordinator`, and `code-review-autofix`.
3. A newly created `config.toml` matches the template; an existing configuration remains unchanged.
