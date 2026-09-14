---
name: codex-setup
description: Install, repair, or verify this dotfiles repository's Codex configuration. Copies the global AGENTS.md, custom agents and personal skills into their user locations, overwriting installed files. Use on a new machine or after adding, renaming, or changing Codex configuration in this repository.
---

# Codex Setup

`setup.sh` installs shell and application configuration but deliberately leaves Codex's user-owned directories alone. This skill installs the Codex layer without replacing shared configuration files.

## Managed sources and targets

| Repository source | User target | Behavior |
| --- | --- | --- |
| `.codex/AGENTS.md` | `${CODEX_HOME:-$HOME/.codex}/AGENTS.md` | copied as the global instruction file |
| `.codex/agents/*.toml` | `${CODEX_HOME:-$HOME/.codex}/agents/` | copied file by file |
| `.agents/skills/<name>/` | `$HOME/.agents/skills/<name>/` | copied file by file; `codex-setup` itself is skipped |

Targets are real directories containing independent file copies. Existing target files are overwritten from dotfiles; legacy file symlinks are removed before copying so their referents are not modified. Symlinked destination directories are refused. Files absent from the source, including machine-local learning logs, are preserved.

## Install

Run:

```sh
sh "$HOME/.dotfiles/.agents/skills/codex-setup/scripts/install.sh"
```

Report the script's output. The operation is idempotent. Re-run it after changing dotfiles to refresh installed copies.

After a source rename, the installer leaves the old target in place. List the target `agents` and skill directories, then remove only confirmed-stale installed copies or broken or confirmed-stale symlinks after resolving their targets. Never delete a machine-local file such as `learnings.md`.

## What is installed

### Global AGENTS.md

`${CODEX_HOME:-$HOME/.codex}/AGENTS.md` loads personal GitHub-writing rules in every repository. Project-level `AGENTS.md` files add repository-specific guidance and closer files take precedence.

### Custom agents

The five custom agents form a staged workflow:

- `planner` — returns a grounded, verifiable plan without editing
- `generator` — implements the assigned plan or verified finding
- `evaluator` — independently checks the result and returns PASS or FAIL
- `reviewer` — runs only an adopted external reviewer and triages its findings
- `reporter` — packages the outcome and performs explicitly authorized publication

Their prohibitions preserve role separation. Read an entire agent file before reducing or moving an instruction.

### Skills

- `$harness` coordinates the five custom agents with durable project state.
- `$code-review-autofix` handles bounded review, fix, push, and re-review cycles.
- `$codex-setup` remains repository-scoped so it does not appear in unrelated projects.

## Verify

Restart Codex after installation, then confirm:

1. Custom agent selection includes `planner`, `generator`, `evaluator`, `reviewer`, and `reporter`.
2. Skill selection includes `harness` and `code-review-autofix`.
