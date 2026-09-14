#!/bin/sh
# Installs this repo's Claude Code configuration into ~/.claude.
#
# Kept out of setup.sh so this skill owns the initial Claude Code setup.
# Existing settings.json belongs to the user and is left unchanged.
# See SKILL.md next to this script.
set -eu

skill_dir=$(cd "$(dirname "$0")" && pwd)
dotpath=$(cd "$skill_dir/../../.." && pwd)
claude_dir="$HOME/.claude"

# Link file by file, never the directory: Claude Code writes runtime state next
# to these files, and a symlinked directory would put that state in this repo.
mkdir -p "$claude_dir/agents" "$claude_dir/rules"

ln -snfv "$dotpath/.claude/CLAUDE.md" "$claude_dir/CLAUDE.md"

for file in "$dotpath/.claude/agents"/*
do
  ln -snfv "$file" "$claude_dir/agents"
done

for file in "$dotpath/.claude/rules"/*
do
  # /bin/sh has no nullglob: an empty dir leaves the '*' literal.
  [ -e "$file" ] || continue
  ln -snfv "$file" "$claude_dir/rules"
done

# Skills too, one directory per skill. claude-setup itself stays a project
# skill of this repo - installed globally it would load everywhere for nothing.
if [ -L "$claude_dir/skills" ]; then
  # Legacy layout: ~/.claude/skills was a symlink to a separate skills repo.
  rm "$claude_dir/skills"
  echo "removed legacy symlink $claude_dir/skills"
fi

for skill in "$dotpath/.claude/skills"/*
do
  name=$(basename "$skill")
  [ "$name" = "claude-setup" ] && continue
  mkdir -p "$claude_dir/skills/$name"
  for file in "$skill"/*
  do
    ln -snfv "$file" "$claude_dir/skills/$name"
  done
done

# Seed settings only when absent; later setup runs preserve user edits.
settings="$claude_dir/settings.json"
if [ -e "$settings" ] || [ -L "$settings" ]; then
  echo "kept existing $settings"
else
  cp -n "$dotpath/.claude/settings.json.template" "$settings"
  echo "initialized $settings from .claude/settings.json.template"
fi
