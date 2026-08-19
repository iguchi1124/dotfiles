---
name: claude-setup
description: Installs this repo's Claude Code configuration into ~/.claude - links CLAUDE.md, the planner/generator/evaluator subagents and the hook scripts, then merges the hook entry into ~/.claude/settings.json. Use when setting up Claude Code on a new machine, after adding or renaming a subagent or a hook in this repo, or when asked to install, repair or verify the Claude Code setup.
---

# claude-setup

`setup.sh` links the shell, vim and tmux config, and stops there. Everything under
`~/.claude` is installed by this skill instead, because one part of it -
`~/.claude/settings.json` - carries machine and project specific values and can only
be merged into, never overwritten.

## What gets installed

| Source in this repo | Target | Notes |
| --- | --- | --- |
| `.claude/CLAUDE.md` | `~/.claude/CLAUDE.md` | Loaded in every session, whatever the working directory. |
| `.claude/agents/*` | `~/.claude/agents/` | Linked file by file, never as a directory. |
| `.claude/hooks/*` | `~/.claude/hooks/` | Linked file by file. Inert until step 2. |
| - | `~/.claude/settings.json` | Merged, never replaced. |

Files are linked individually rather than linking the directory, for the same reason
as `.config/<app>/` in `setup.sh`: Claude Code writes runtime state (sessions, caches,
history) into these directories, and a symlinked directory would drop that state into
this repo.

## 1. Link the files

Idempotent, and safe to re-run after adding an agent or a hook:

```sh
sh "$HOME/.dotfiles/.claude/skills/claude-setup/install.sh"
```

Report what it printed. Re-running after a rename leaves the old link behind - list
`~/.claude/agents` and `~/.claude/hooks` and remove any symlink whose target no longer
exists.

## 2. Register the hook in settings.json

Linking a hook script does nothing on its own: `~/.claude/settings.json` is what invokes
it. `install.sh` merges the entry when `jq` is available (`jq` is in `.Brewfile`). It
preserves every other key, and re-running changes nothing.

If `jq` was missing, install it and re-run step 1, or merge this by hand:

```json
"hooks": {
  "PreToolUse": [
    {
      "matcher": "Bash",
      "hooks": [
        { "type": "command", "command": "sh \"$HOME/.claude/hooks/load-env-sh.sh\"", "timeout": 10 }
      ]
    }
  ]
}
```

Keep `$HOME` literal in the command - the shell expands it when the hook runs, not when
it is written.

## 3. Verify

Claude Code only picks up settings changes for directories that already had a settings
file when the session started, so open `/hooks` once or restart Claude Code first. Then,
from any project:

```sh
printf 'export DOTFILES_HOOK_CHECK=ok\n' > env.sh
echo $DOTFILES_HOOK_CHECK   # through the Bash tool - must print: ok
rm env.sh
```

Also confirm the subagents are visible: `planner`, `generator` and `evaluator` should be
listed as available agent types.

## What is installed

### Global CLAUDE.md

`~/.claude/CLAUDE.md` is read in every session regardless of the working directory.
Project level `CLAUDE.md` files are read in addition to it, and win where they conflict.

### Subagents

Available from any project, and built to chain - the planner's plan feeds the generator,
and the evaluator's findings hand straight back to the generator:

- **planner** - breaks a task into verifiable steps; writes no code
- **generator** - implements a plan and gets lint and tests passing
- **evaluator** - checks the result and returns PASS/FAIL with reproducible findings

Each one's prohibitions are what keep that separation intact, so read the whole file
before trimming one.

### load-env-sh.sh

Sources `./env.sh` from the working directory root, if present, before every Bash
command. `env.sh` is in the global gitignore (`.config/git/ignore`), so it is the
per-project spot for local environment variables.

It runs on `PreToolUse`, not `SessionStart`, because Claude Code starts a fresh shell for
every Bash command and carries no environment variables over - sourcing once at session
start would have no effect. The hook instead rewrites each command to source `env.sh`
first. The working directory is reset to the project root after every command, so the
check always applies to the project root.

A broken hook can never block a command: the script exits 0 without rewriting anything if
`env.sh` is absent, if `jq` is missing, or if the payload is unexpected.
