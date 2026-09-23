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

Vim config lives in `.config/vim/` (Vim 9.1.0327+ reads `$XDG_CONFIG_HOME/vim/vimrc` when `~/.vimrc` and `~/.vim/vimrc` are absent), tmux config in `.config/tmux/` (tmux 3.2+ reads `$XDG_CONFIG_HOME/tmux/tmux.conf` when `~/.tmux.conf` is absent; 3.1 only knows the literal `~/.config/tmux/tmux.conf` path). Plugins and netrw state go to `$XDG_DATA_HOME/vim`, vim-plug itself to `$XDG_CONFIG_HOME/vim/autoload/`.

`setup.sh` also installs vim-plug and Homebrew when missing. Zsh plugins (`zsh-autosuggestions`, `zsh-syntax-highlighting`) and completions are Homebrew packages managed through `.Brewfile`.

It installs nothing under `~/.claude` — that is the `claude-setup` skill's job, see below.

It also installs nothing under `~/.codex` or `~/.agents` — that is the
`codex-setup` skill's job.

## Claude Code setup

`.claude/` holds the Claude Code configuration — `CLAUDE.md`, the `planner` / `generator` / `evaluator` custom subagents, the `orchestrator` skill that uses them for Plan, Generate, and Evaluate, and the `coordinator` skill for durable multi-task and multi-agent project state shared with Codex under each project's `.coordinator/` — but `setup.sh` installs none of it. The installer initializes `~/.claude/settings.json` from the template only when it is absent; existing machine- and project-specific settings remain unchanged.

`.claude/skills/claude-setup/` is the skill that does it: it copies owned files individually into `~/.claude`, overwriting installed copies while preserving machine-local files, copies the settings template only when `settings.json` is absent, and documents how to verify the result. It is a project skill of this repo, so it loads whenever Claude Code runs here. To install or refresh by hand, run its script directly:

```sh
sh "$HOME/.dotfiles/.claude/skills/claude-setup/install.sh"
```

That skill is also where the rationale lives — why files are copied individually into real directories, what each stage is for and how custom definitions or explicit caller prompts preserve its boundaries. Legacy file symlinks are replaced with copies; directory symlinks are refused. Re-run the installer after source changes and compare changed managed files with their installed copies. Read the skill before changing anything under `.claude/`.

A skill shared with Codex has one source in `.agents/skills/<name>/`, and `.claude/skills/<name>` is a relative symlink to it (Claude Code reads only `.claude/skills/`, Codex only `.agents/skills/`). `orchestrator` and `coordinator` are both shared this way; the installer follows the link and installs real copies. Tool differences (agent type names, worktree tooling, learning-log paths) are spelled out inside the one source. Only `claude-setup` and `codex-setup` are tool-specific.

The conversation parent uses coordinator to create and maintain shared `spec.md`
and `tasks.md`, with a root-level writer lock covering project selection and updates.
Orchestrator executes one task in a dedicated worktree with isolated role contexts
and its own `task.md`; it links to the shared board rather than managing or copying it.

## Codex setup

`.codex/` holds Codex's global `AGENTS.md`, custom-agent TOML files, and the initial `config.toml.template`. `.agents/skills/` holds the `orchestrator`,
`coordinator`, and repository-scoped `codex-setup` skills.
The first two are the single sources for both tools, linked from `.claude/skills/`;
`coordinator` shares each project's `.coordinator/` state and `orchestrator` its
`.orchestrator/` task state.

Install them with:

```sh
sh "$HOME/.dotfiles/.agents/skills/codex-setup/scripts/install.sh"
```

The installer copies owned files individually, preserving machine-local files, and copies the config template only when `config.toml` is absent. Re-run it after source changes and compare changed managed files with their installed copies. Read the `codex-setup` skill before changing either
Codex configuration tree.
