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
- **Top-level files** (`.zshrc`, `.zshenv`, `.zprofile`, `.Brewfile`) — symlinked straight into `$HOME`.

Vim config lives in `.config/vim/` (Vim 9.1.0327+ reads `$XDG_CONFIG_HOME/vim/vimrc` when `~/.vimrc` and `~/.vim/vimrc` are absent), tmux config in `.config/tmux/` (tmux 3.1+ reads `$XDG_CONFIG_HOME/tmux/tmux.conf` when `~/.tmux.conf` is absent). Plugins and netrw state go to `$XDG_DATA_HOME/vim`, vim-plug itself to `$XDG_CONFIG_HOME/vim/autoload/`.

`setup.sh` also installs vim-plug and Homebrew when missing. Zsh plugins (`zsh-autosuggestions`, `zsh-syntax-highlighting`) and completions are Homebrew packages managed through `.Brewfile`.

It installs nothing under `~/.claude` — that is the `claude-setup` skill's job, see below.

## Claude Code setup

`.claude/` holds the Claude Code configuration — `CLAUDE.md`, the `planner` / `generator` / `evaluator` / `reviewer` / `reporter` subagents, the `harness` skill that chains them, and the `load-env-sh.sh` hook — but `setup.sh` installs none of it. Installing ends in a merge into `~/.claude/settings.json`, which is what actually invokes a hook and which also carries machine- and project-specific values, so it can only be merged into, never overwritten.

`.claude/skills/claude-setup/` is the skill that does it: it links the files into `~/.claude`, merges the hook entry into `settings.json`, and documents how to verify the result. It is a project skill of this repo, so it loads whenever Claude Code runs here. To install by hand, run its script directly:

```sh
sh "$HOME/.dotfiles/.claude/skills/claude-setup/install.sh"
```

That skill is also where the rationale lives — why files are linked individually, what each subagent is for and why their prohibitions matter, and why the hook runs on `PreToolUse` rather than `SessionStart`. Read it before changing anything under `.claude/`.
