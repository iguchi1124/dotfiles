#!/bin/sh
# Install this repository's Codex configuration without replacing shared files.
set -eu

script_dir=$(cd "$(dirname "$0")" && pwd)
dotpath=$(cd "$script_dir/../../../.." && pwd)
codex_dir=${CODEX_HOME:-"$HOME/.codex"}
personal_skills_dir="$HOME/.agents/skills"

for dir in "$codex_dir/agents" "$codex_dir/hooks" "$HOME/.agents" "$personal_skills_dir"
do
  if [ -L "$dir" ]; then
    echo "refusing symlinked runtime directory: $dir" >&2
    exit 1
  fi
done

mkdir -p "$codex_dir/agents" "$codex_dir/hooks" "$personal_skills_dir"

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

for file in "$dotpath/.codex/hooks"/*
do
  [ -e "$file" ] || continue
  copy_file "$file" "$codex_dir/hooks/$(basename "$file")"
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

if ! command -v jq >/dev/null 2>&1; then
  echo "jq not found: skipped the hooks.json merge (jq is in .Brewfile)." >&2
  echo "Install jq and re-run; files are already copied." >&2
  exit 0
fi

hooks_file="$codex_dir/hooks.json"
if [ -L "$hooks_file" ]; then
  echo "refusing to merge through symlinked hooks file: $hooks_file" >&2
  exit 1
fi
[ -f "$hooks_file" ] || printf '{}\n' > "$hooks_file"

temp_file=$(mktemp "${TMPDIR:-/tmp}/codex-hooks.XXXXXX")
trap 'rm -f "$temp_file"' EXIT HUP INT TERM
hook_command="sh \"$codex_dir/hooks/load-env-sh.sh\""

jq --arg command "$hook_command" '
  def entry: {
    type: "command",
    command: $command,
    timeout: 10,
    statusMessage: "Loading project env.sh"
  };
  .hooks //= {}
  | .hooks.PreToolUse //= []
  | if (.hooks.PreToolUse | map(select(.matcher == "Bash")) | length) == 0
    then .hooks.PreToolUse += [{matcher: "Bash", hooks: [entry]}]
    else .hooks.PreToolUse |= map(
      if .matcher == "Bash"
      then .hooks = ((.hooks // []) | if (map(.command) | index($command)) then . else . + [entry] end)
      else .
      end
    )
    end
' "$hooks_file" > "$temp_file"

mv "$temp_file" "$hooks_file"
trap - EXIT HUP INT TERM

echo "merged the PreToolUse(Bash) env hook into $hooks_file"
echo "restart Codex, then inspect and trust the hook with /hooks"
