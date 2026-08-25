#!/bin/sh
# Installs this repo's Claude Code configuration into ~/.claude.
#
# Kept out of setup.sh because the last step edits ~/.claude/settings.json, which
# also holds machine- and project-specific values and so can only be merged into.
# See SKILL.md next to this script.
set -eu

skill_dir=$(cd "$(dirname "$0")" && pwd)
dotpath=$(cd "$skill_dir/../../.." && pwd)
claude_dir="$HOME/.claude"

# Link file by file, never the directory: Claude Code writes runtime state next
# to these files, and a symlinked directory would put that state in this repo.
mkdir -p "$claude_dir/agents" "$claude_dir/hooks" "$claude_dir/rules"

ln -snfv "$dotpath/.claude/CLAUDE.md" "$claude_dir/CLAUDE.md"

for file in "$dotpath/.claude/agents"/*
do
  ln -snfv "$file" "$claude_dir/agents"
done

for file in "$dotpath/.claude/hooks"/*
do
  ln -snfv "$file" "$claude_dir/hooks"
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

# Plugins come from marketplaces, not from this repo, so they are installed
# through the claude CLI rather than linked. Both commands are idempotent.
# One "<marketplace> <github-repo> <plugin>..." line per marketplace.
plugins='
claude-community anthropics/claude-plugins-community eli5
'

if command -v claude > /dev/null 2>&1; then
  printf '%s\n' "$plugins" | while read -r marketplace repo names
  do
    [ -n "$marketplace" ] || continue
    claude plugin marketplace add "$repo"
    for name in $names
    do
      claude plugin install "$name@$marketplace"
    done
  done
else
  echo "claude not found: skipped the plugin install (eli5@claude-community)." >&2
  echo "Install Claude Code and re-run - see SKILL.md." >&2
fi

# A linked hook script does nothing until settings.json invokes it. Merge the
# entry in, preserving every other key; re-running changes nothing.
settings="$claude_dir/settings.json"

if ! command -v jq > /dev/null 2>&1; then
  echo "jq not found: skipped the settings.json merge (jq is in .Brewfile)." >&2
  echo "Install jq and re-run, or merge the hook entry by hand - see SKILL.md." >&2
  exit 0
fi

[ -f "$settings" ] || echo '{}' > "$settings"

# Keep $HOME literal - the shell expands it when the hook runs, not now.
merged="$(jq --arg cmd 'sh "$HOME/.claude/hooks/load-env-sh.sh"' '
  def entry: {type: "command", command: $cmd, timeout: 10};
  .hooks //= {}
  | .hooks.PreToolUse //= []
  | if (.hooks.PreToolUse | map(select(.matcher == "Bash")) | length) == 0
    then .hooks.PreToolUse += [{matcher: "Bash", hooks: [entry]}]
    else .hooks.PreToolUse |= map(
      if .matcher == "Bash"
      then .hooks = ((.hooks // []) | if (map(.command) | index($cmd)) then . else . + [entry] end)
      else . end)
    end
' "$settings")" && printf '%s\n' "$merged" > "$settings"

echo "merged the PreToolUse(Bash) hook entry into $settings"
