---
name: claude-setup
description: Install, repair, or verify this repository's Claude Code configuration after setup or source changes.
---

# Claude Setup

Run `sh "$HOME/.dotfiles/.agents/skills/claude-setup/install.sh"` and report its output. The installer copies `.claude/CLAUDE.md`, `.claude/agents/*`, and shared skills from `.claude/skills/` into `~/.claude/`. The source skills directory links to `.agents/skills/`; the two setup skills stay repository-scoped. Targets are independent files in real directories; symlinked destinations are refused. Files absent from source remain installed.

The installer creates `settings.json` from `.claude/settings.json.template` only when absent; it preserves existing files and symlinks. After source changes, rerun it and compare each changed managed source with its installed copy using `cmp`. Compare the template only if this run created `settings.json`. Report any refresh or comparison failure separately. Restart Claude Code to load refreshed prompts.
