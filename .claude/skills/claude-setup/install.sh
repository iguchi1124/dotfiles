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

# Copy file by file into real directories so runtime state stays on this machine.
for dir in "$claude_dir" "$claude_dir/agents" "$claude_dir/rules" "$claude_dir/skills"
do
  if [ -L "$dir" ]; then
    echo "refusing symlinked runtime directory: $dir" >&2
    exit 1
  fi
done

copy_file() {
  source_file=$1
  target_file=$2

  target_parent=$(dirname "$target_file")
  while [ "$target_parent" != / ] && [ "$target_parent" != . ]; do
    if [ -L "$target_parent" ]; then
      echo "refusing symlinked runtime directory: $target_parent" >&2
      exit 1
    fi
    target_parent=$(dirname "$target_parent")
  done

  if [ -d "$target_file" ] && [ ! -L "$target_file" ]; then
    echo "refusing to replace existing directory: $target_file" >&2
    exit 1
  fi

  mkdir -p "$(dirname "$target_file")"
  # Remove legacy links first so copying never writes through to their sources.
  if [ -L "$target_file" ]; then
    rm "$target_file"
  fi
  cp -pv "$source_file" "$target_file"
}

copy_file "$dotpath/.claude/CLAUDE.md" "$claude_dir/CLAUDE.md"
mkdir -p "$claude_dir/agents" "$claude_dir/rules" "$claude_dir/skills"

for file in "$dotpath/.claude/agents"/*
do
  [ -f "$file" ] || continue
  copy_file "$file" "$claude_dir/agents/$(basename "$file")"
done

for file in "$dotpath/.claude/rules"/*
do
  # /bin/sh has no nullglob: an empty dir leaves the '*' literal.
  [ -f "$file" ] || continue
  copy_file "$file" "$claude_dir/rules/$(basename "$file")"
done

# Skills too, one directory per skill. claude-setup itself stays a project
# skill of this repo - installed globally it would load everywhere for nothing.
for skill in "$dotpath/.claude/skills"/*
do
  [ -d "$skill" ] || continue
  name=$(basename "$skill")
  [ "$name" = "claude-setup" ] && continue
  if [ -L "$claude_dir/skills/$name" ]; then
    echo "refusing symlinked runtime directory: $claude_dir/skills/$name" >&2
    exit 1
  fi
  find "$skill" -type f | while IFS= read -r file
  do
    relative=${file#"$skill"/}
    copy_file "$file" "$claude_dir/skills/$name/$relative"
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
