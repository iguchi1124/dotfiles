#!/bin/sh
# Codex PreToolUse(Bash) hook: load ./env.sh for each shell command.
#
# Codex runs commands in fresh shells. Rewriting each command keeps project-local
# environment variables available without copying them into managed config.

[ -f ./env.sh ] || exit 0
command -v jq >/dev/null 2>&1 || exit 0

jq -c '
  if .tool_name == "Bash"
     and (.tool_input | type) == "object"
     and (.tool_input.command | type) == "string"
  then {
    hookSpecificOutput: {
      hookEventName: "PreToolUse",
      permissionDecision: "allow",
      updatedInput: (.tool_input | .command = ("[ -f ./env.sh ] && . ./env.sh; " + .command))
    }
  }
  else empty
  end
' || exit 0
