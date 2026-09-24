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
for dir in "$claude_dir" "$claude_dir/agents" "$claude_dir/skills"
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
  # Prepare copies before removing legacy links; never write through to sources.
  if [ -L "$target_file" ]; then
    (
      copy_temp=$(mktemp "$(dirname "$target_file")/.claude-setup.XXXXXXXXXX")
      trap 'rm -f "$copy_temp"' 0
      trap 'exit 1' HUP INT TERM
      cp -pv "$source_file" "$copy_temp"
      # Unlink explicitly: mv can follow a destination link to a directory.
      rm "$target_file"
      mv "$copy_temp" "$target_file"
    )
  else
    cp -pv "$source_file" "$target_file"
  fi
}

copy_file "$dotpath/.claude/CLAUDE.md" "$claude_dir/CLAUDE.md"
mkdir -p "$claude_dir/agents" "$claude_dir/skills"

for file in "$dotpath/.claude/agents"/*
do
  [ -f "$file" ] || continue
  copy_file "$file" "$claude_dir/agents/$(basename "$file")"
done

# .claude/skills links to .agents/skills. Install global skills as real copies;
# both setup skills need this repository and remain project-local.
skill_files=$(mktemp "${TMPDIR:-/tmp}/claude-setup.XXXXXXXXXX")
trap 'rm -f "$skill_files"' 0
trap 'exit 1' HUP INT TERM
for skill in "$dotpath/.claude/skills"/*
do
  [ -d "$skill" ] || continue
  name=$(basename "$skill")
  case "$name" in
    claude-setup|codex-setup) continue ;;
  esac
  if [ -L "$claude_dir/skills/$name" ]; then
    echo "refusing symlinked runtime directory: $claude_dir/skills/$name" >&2
    exit 1
  fi
  # Check traversal separately: a pipeline would hide find failures in /bin/sh.
  find -H "$skill" -type f > "$skill_files"
  while IFS= read -r file
  do
    relative=${file#"$skill"/}
    copy_file "$file" "$claude_dir/skills/$name/$relative"
  done < "$skill_files"
done

# Seed settings only when absent; later setup runs preserve user edits.
settings="$claude_dir/settings.json"
if [ -e "$settings" ] || [ -L "$settings" ]; then
  echo "kept existing $settings"
else
  cp -n "$dotpath/.claude/settings.json.template" "$settings"
  echo "initialized $settings from .claude/settings.json.template"
fi
