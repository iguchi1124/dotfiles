# Dotfiles

Design principles are in [DESIGN.md](DESIGN.md).

## Install

```
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/iguchi1124/dotfiles/main/setup.sh)"
```

## Claude Code

Claude Code configuration is installed separately from `setup.sh` by the
repository's `claude-setup` skill:

```sh
sh "$HOME/.dotfiles/.claude/skills/claude-setup/install.sh"
```

See [.claude/skills/claude-setup/SKILL.md](.claude/skills/claude-setup/SKILL.md).

## Codex

Codex configuration is installed separately from `setup.sh` by the
repository's `codex-setup` skill:

```sh
sh "$HOME/.dotfiles/.agents/skills/codex-setup/scripts/install.sh"
```

See [.agents/skills/codex-setup/SKILL.md](.agents/skills/codex-setup/SKILL.md).
