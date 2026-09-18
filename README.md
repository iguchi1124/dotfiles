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

A skill shared by both tools lives once in `.agents/skills/<name>/`, with
`.claude/skills/<name>` a symlink to it; `orchestrator`, `coordinator`, and
`code-review-autofix` are shared this way.

Both setup skills copy managed files individually into real directories. Re-run
the corresponding installer after editing the dotfiles sources, then use `cmp` to
compare changed sources refreshed by the installer with their installed copies.
Compare `config.toml.template` or `settings.json.template` with its destination only
when this run created that previously absent file. Existing user settings files
and symlinks are preserved and need not match the templates; machine-local learning
logs are also preserved. Legacy managed file symlinks are replaced with copies;
symlinked destination directories are refused.
