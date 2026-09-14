#!/bin/sh
# Install this repository's Codex configuration without replacing shared files.
set -eu

script_dir=$(cd "$(dirname "$0")" && pwd)
dotpath=$(cd "$script_dir/../../../.." && pwd)
codex_dir=${CODEX_HOME:-"$HOME/.codex"}
personal_skills_dir="$HOME/.agents/skills"

for dir in "$codex_dir/agents" "$HOME/.agents" "$personal_skills_dir"
do
  if [ -L "$dir" ]; then
    echo "refusing symlinked runtime directory: $dir" >&2
    exit 1
  fi
done

mkdir -p "$codex_dir/agents" "$personal_skills_dir"

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

copy_file "$dotpath/.codex/AGENTS.md" "$codex_dir/AGENTS.md"

for file in "$dotpath/.codex/agents"/*.toml
do
  [ -e "$file" ] || continue
  copy_file "$file" "$codex_dir/agents/$(basename "$file")"
done

for skill in "$dotpath/.agents/skills"/*
do
  [ -d "$skill" ] || continue
  name=$(basename "$skill")
  [ "$name" = "codex-setup" ] && continue

  mkdir -p "$personal_skills_dir/$name"
  find "$skill" -type f | while IFS= read -r file
  do
    relative=${file#"$skill"/}
    copy_file "$file" "$personal_skills_dir/$name/$relative"
  done
done

# Seed user configuration only when absent; later setup runs preserve user edits.
config_file="$codex_dir/config.toml"
if [ -e "$config_file" ] || [ -L "$config_file" ]; then
  echo "kept existing $config_file"
else
  cp -n "$dotpath/.codex/config.toml.template" "$config_file"
  echo "initialized $config_file from .codex/config.toml.template"
fi
