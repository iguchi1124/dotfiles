---
name: codex-setup
description: Install, repair, or verify this repository's Codex configuration after setup or source changes.
---

# Codex Setup

Run `sh "$HOME/.dotfiles/.agents/skills/codex-setup/scripts/install.sh"` and report its output. The installer copies `.codex/AGENTS.md`, `.codex/agents/*.toml`, and shared skills from `.agents/skills/` into `${CODEX_HOME:-$HOME/.codex}` and `~/.agents/skills`. The two setup skills stay repository-scoped. Targets are independent files in real directories; symlinked destinations are refused. Files absent from source remain installed.

The installer creates `config.toml` from `.codex/config.toml.template` only when absent; it preserves existing files and symlinks. After source changes, rerun it and compare each changed managed source with its installed copy using `cmp`. Compare the template only if this run created `config.toml`. Report any refresh or comparison failure separately. Restart Codex to load refreshed prompts.
