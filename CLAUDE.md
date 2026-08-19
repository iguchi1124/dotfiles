# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

Personal dotfiles for macOS and Linux, installed with:

```sh
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/iguchi1124/dotfiles/main/setup.sh)"
```

`setup.sh` is idempotent and safe to re-run after adding files.

## How setup.sh links things

Two different strategies, and the distinction matters when adding new config:

- **`.config/<app>/`** — the *directory* is created for real at `$XDG_CONFIG_HOME/<app>/` and each file inside is symlinked individually. Never symlink the directory itself: apps write runtime files (logs, sockets, caches) next to their config, and a symlinked directory would put that state inside this repo.
- **Top-level files** (`.zshrc`, `.vimrc`, `.tmux.conf`, `.zshenv`, `.zprofile`, `.Brewfile`) — symlinked straight into `$HOME`.

`setup.sh` also installs oh-my-zsh, its plugins, vim-plug, and Homebrew when missing.

Under `~/.claude` it links two things: `.claude/CLAUDE.md` and everything in `.claude/agents/`. Neither holds machine or project specific values, so both can be linked unconditionally. Hooks are deliberately excluded — see below.

## Global CLAUDE.md

`.claude/CLAUDE.md` is symlinked to `~/.claude/CLAUDE.md`, which Claude Code loads in every session regardless of the working directory. Project level `CLAUDE.md` files are read in addition to it, and win where the two conflict.

## Subagents

`.claude/agents/` holds user level subagent definitions, each symlinked into `~/.claude/agents/`. They are available from any project. Files are linked individually rather than linking the directory, for the same reason as `.config/<app>/`.

- **planner** — breaks a task into verifiable steps; writes no code
- **generator** — implements a plan and gets lint and tests passing
- **evaluator** — checks the result and returns PASS/FAIL with reproducible findings

They are built to chain: planner's plan feeds generator, and evaluator's findings hand straight back to generator. Each one's prohibitions are what keep that separation intact, so read the whole file before trimming one.

## Claude Code hooks

`.claude/hooks/` holds hook scripts, but **`setup.sh` does not install them** — `~/.claude/settings.json` is what actually invokes a hook, and that file carries machine and project specific values, so it is not managed in this repo. Installing a hook therefore has two steps, both of which have to be done outside `setup.sh`.

### load-env-sh.sh

Sources `./env.sh` from the working directory root, if present, before every Bash command. `env.sh` is in the global gitignore (`.config/git/ignore`), so it is the per-project spot for local environment variables.

It runs on `PreToolUse`, not `SessionStart`, because Claude Code starts a fresh shell for every Bash command and carries no environment variables over — sourcing once at session start would have no effect. The hook instead rewrites each command to source `env.sh` first. The working directory is reset to the project root after every command, so the check always applies to the project root.

### Installing it

1. Link the scripts:

   ```sh
   mkdir -p "$HOME/.claude/hooks"
   ln -snfv "$HOME/.dotfiles/.claude/hooks/"* "$HOME/.claude/hooks"
   ```

2. Merge the entry into `~/.claude/settings.json`. Requires `jq` (in `.Brewfile`). This preserves every other key, and re-running it changes nothing:

   ```sh
   settings="$HOME/.claude/settings.json"
   [ -f "$settings" ] || echo '{}' > "$settings"

   merged="$(jq --arg cmd 'sh "$HOME/.claude/hooks/load-env-sh.sh"' '
     def entry: {type: "command", command: $cmd, timeout: 10};
     .hooks //= {}
     | .hooks.PreToolUse //= []
     | if (.hooks.PreToolUse | map(select(.matcher == "Bash")) | length) == 0
       then .hooks.PreToolUse += [{matcher: "Bash", hooks: [entry]}]
       else .hooks.PreToolUse |= map(
         if .matcher == "Bash"
         then .hooks = ((.hooks // []) | if (map(.command) | index($cmd)) then . else . + [entry] end)
         else . end)
       end
   ' "$settings")" && printf '%s\n' "$merged" > "$settings"
   ```

   Keep `$HOME` literal inside `--arg cmd` — the hook command is expanded by the shell when it runs, not now.

3. Verify. Claude Code only picks up settings changes for directories that already had a settings file when the session started, so open `/hooks` once or restart first. Then, from any project:

   ```sh
   printf 'export DOTFILES_HOOK_CHECK=ok\n' > env.sh
   ```

   Have Claude run `echo $DOTFILES_HOOK_CHECK` through its Bash tool — it should print `ok`. Then `rm env.sh`.

A broken hook can never block a command: the script exits 0 without rewriting anything if `env.sh` is absent, if `jq` is missing, or if the payload is unexpected.
