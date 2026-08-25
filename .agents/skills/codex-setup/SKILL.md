---
name: codex-setup
description: Install, repair, or verify this dotfiles repository's Codex configuration. Links the global AGENTS.md, custom agents, hook scripts, and personal skills into their user locations, then merges the env hook into hooks.json. Use on a new machine or after adding, renaming, or changing Codex configuration in this repository.
---

# Codex Setup

`setup.sh` installs shell and application configuration but deliberately leaves Codex's user-owned directories alone. This skill installs the Codex layer without replacing shared configuration files.

## Managed sources and targets

| Repository source | User target | Behavior |
| --- | --- | --- |
| `.codex/AGENTS.md` | `${CODEX_HOME:-$HOME/.codex}/AGENTS.md` | linked as the global instruction file |
| `.codex/agents/*.toml` | `${CODEX_HOME:-$HOME/.codex}/agents/` | linked file by file |
| `.codex/hooks/*` | `${CODEX_HOME:-$HOME/.codex}/hooks/` | linked file by file; inert until registered |
| `.agents/skills/<name>/` | `$HOME/.agents/skills/<name>/` | linked file by file; `codex-setup` itself is skipped |
| hook entry | `${CODEX_HOME:-$HOME/.codex}/hooks.json` | merged with `jq`, never replaced |

Targets are real directories. Linking whole directories would allow Codex runtime files, histories, caches, and machine-local learning logs to enter this repository.

## Install

Run:

```sh
sh "$HOME/.dotfiles/.agents/skills/codex-setup/scripts/install.sh"
```

Report the script's output. The operation is idempotent. It refuses to replace a real target file managed elsewhere and preserves every unrelated key in `hooks.json`.

After a source rename, the installer cannot know whether an old target symlink is still wanted. List the target `agents`, `hooks`, and skill directories, then remove only broken or confirmed-stale symlinks after resolving their targets. Never delete a real machine-local file such as `learnings.md`.

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

### env.sh hook

The `PreToolUse` Bash hook rewrites each command to source project-root `env.sh` when present. Shell commands use fresh processes, so a one-time session hook would not persist environment variables.

The script returns success without a rewrite if `env.sh` or `jq` is missing, or if input does not match the expected Bash shape. It therefore cannot intentionally block a command.

Codex requires trust for non-managed hooks. After installation or any hook change, restart Codex, open `/hooks`, inspect the exact command and source, and trust it before verification.

## Verify

Restart Codex after installation, then confirm:

1. Custom agent selection includes `planner`, `generator`, `evaluator`, `reviewer`, and `reporter`.
2. Skill selection includes `harness` and `code-review-autofix`.
3. `/hooks` shows the `PreToolUse` Bash hook from user `hooks.json` as trusted.
4. In a disposable test project, create an ignored `env.sh` containing `export DOTFILES_HOOK_CHECK=ok`; a subsequent shell tool call should print `ok`. Remove the test file afterward.

Do not modify a real project's `env.sh` for verification without permission.
