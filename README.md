# Dotfiles

Design principles are in [DESIGN.md](DESIGN.md).

## Install

```
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/iguchi1124/dotfiles/main/setup.sh)"
```

## Claude Code

Everything under `~/.claude` is installed separately from `setup.sh`, by the
`claude-setup` skill in this repo:

```
sh "$HOME/.dotfiles/.claude/skills/claude-setup/install.sh"
```

See [.claude/skills/claude-setup/SKILL.md](.claude/skills/claude-setup/SKILL.md).

## Codex

Codex custom agents, skills, and global instructions are installed
separately from `setup.sh` by the repository's `codex-setup` skill:

```sh
sh "$HOME/.dotfiles/.agents/skills/codex-setup/scripts/install.sh"
```

See [.agents/skills/codex-setup/SKILL.md](.agents/skills/codex-setup/SKILL.md).

Both setup skills copy managed files individually into real directories. Re-run
the corresponding installer after editing the dotfiles sources, then compare the
changed files with their installed copies. Existing user settings and machine-local
learning logs are preserved. Legacy file symlinks are replaced with copies;
symlinked destination directories are refused.
