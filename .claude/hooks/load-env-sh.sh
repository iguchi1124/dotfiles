#!/bin/sh
# Claude Code PreToolUse(Bash) hook: auto-load ./env.sh when present.
#
# The Bash tool starts a fresh shell for every command and does not carry
# environment variables over, so sourcing env.sh once at SessionStart has no
# effect. Instead this hook rewrites each Bash command to source env.sh first.
#
# Linking this script does nothing on its own - ~/.claude/settings.json is what
# invokes it. That file is not managed in this repo because it also holds
# machine/project specific values, and setup.sh deliberately leaves ~/.claude
# alone, so the entry below is installed separately. See CLAUDE.md.
#
#   "hooks": {
#     "PreToolUse": [
#       {
#         "matcher": "Bash",
#         "hooks": [
#           { "type": "command",
#             "command": "sh \"$HOME/.claude/hooks/load-env-sh.sh\"",
#             "timeout": 10 }
#         ]
#       }
#     ]
#   }

# The Bash tool resets the working directory to the project root after every
# command, so this always tests the project root - matching the intent of
# "env.sh sitting directly in the working directory".
[ -f ./env.sh ] || exit 0

# Emit no rewrite (rather than an error) if jq is missing or the payload is not
# what we expect, so a broken hook can never block a command.
jq -c '{
  hookSpecificOutput: {
    hookEventName: "PreToolUse",
    updatedInput: (.tool_input | .command = ("[ -f ./env.sh ] && source ./env.sh; " + .command))
  }
}' || exit 0
