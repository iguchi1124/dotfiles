# Dotfiles

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
