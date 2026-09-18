#!/bin/sh
# Run against an isolated source tree and destination without changing HOME.
set -eu

test_dir=$(cd "$(dirname "$0")" && pwd)
fixture=$(mktemp -d "${TMPDIR:-/tmp}/claude-setup-test.XXXXXXXXXX")
trap 'rm -rf "$fixture"' 0
trap 'exit 1' HUP INT TERM
fixture=$(cd "$fixture" && pwd -P)

source_dir="$fixture/repo/.claude"
install_script="$source_dir/skills/claude-setup/install.sh"
mkdir -p "$source_dir/skills/claude-setup" "$source_dir/agents" \
  "$source_dir/rules" "$source_dir/skills/example skill/nested path" \
  "$fixture/repo/.agents/skills/shared skill/scripts" "$fixture/bin" "$fixture/tmp"
sed 's|^claude_dir=.*|claude_dir="$CLAUDE_TEST_DEST"|' \
  "$test_dir/../install.sh" > "$install_script"
printf 'global instructions\n' > "$source_dir/CLAUDE.md"
printf 'agent\n' > "$source_dir/agents/example.md"
printf 'rule\n' > "$source_dir/rules/example.md"
printf 'skill\n' > "$source_dir/skills/example skill/SKILL.md"
printf 'nested\n' > "$source_dir/skills/example skill/nested path/file name.md"
printf '{}\n' > "$source_dir/settings.json.template"
# A skill shared with Codex lives in .agents/skills and is linked from .claude/skills.
printf 'shared skill\n' > "$fixture/repo/.agents/skills/shared skill/SKILL.md"
printf 'shared script\n' > "$fixture/repo/.agents/skills/shared skill/scripts/run.sh"
ln -s "../../.agents/skills/shared skill" "$source_dir/skills/shared skill"

assert_clean_tmp() {
  for temporary_file in "$fixture/tmp"/* "$CLAUDE_TEST_DEST"/.claude-setup.*; do
    if [ -e "$temporary_file" ] || [ -L "$temporary_file" ]; then
      echo "temporary artifact left behind: $temporary_file" >&2
      exit 1
    fi
  done
}

CLAUDE_TEST_DEST="$fixture/success"
TMPDIR="$fixture/tmp"
export CLAUDE_TEST_DEST TMPDIR
sh "$install_script" > "$fixture/success.log" 2>&1 || {
  cat "$fixture/success.log" >&2
  exit 1
}
cmp "$source_dir/CLAUDE.md" "$CLAUDE_TEST_DEST/CLAUDE.md"
cmp "$source_dir/agents/example.md" "$CLAUDE_TEST_DEST/agents/example.md"
cmp "$source_dir/rules/example.md" "$CLAUDE_TEST_DEST/rules/example.md"
cmp "$source_dir/skills/example skill/SKILL.md" \
  "$CLAUDE_TEST_DEST/skills/example skill/SKILL.md"
cmp "$source_dir/skills/example skill/nested path/file name.md" \
  "$CLAUDE_TEST_DEST/skills/example skill/nested path/file name.md"
cmp "$source_dir/settings.json.template" "$CLAUDE_TEST_DEST/settings.json"
[ ! -e "$CLAUDE_TEST_DEST/skills/claude-setup" ]
[ -d "$CLAUDE_TEST_DEST/skills/shared skill" ] && [ ! -L "$CLAUDE_TEST_DEST/skills/shared skill" ]
[ ! -L "$CLAUDE_TEST_DEST/skills/shared skill/SKILL.md" ]
cmp "$fixture/repo/.agents/skills/shared skill/SKILL.md" \
  "$CLAUDE_TEST_DEST/skills/shared skill/SKILL.md"
cmp "$fixture/repo/.agents/skills/shared skill/scripts/run.sh" \
  "$CLAUDE_TEST_DEST/skills/shared skill/scripts/run.sh"
assert_clean_tmp

printf 'local settings\n' > "$CLAUDE_TEST_DEST/settings.json"
cp "$CLAUDE_TEST_DEST/settings.json" "$fixture/expected-settings"
printf 'local learning\n' > "$CLAUDE_TEST_DEST/skills/example skill/learnings.md"
cp "$CLAUDE_TEST_DEST/skills/example skill/learnings.md" "$fixture/expected-learning"
sh "$install_script" >> "$fixture/success.log" 2>&1 || {
  cat "$fixture/success.log" >&2
  exit 1
}
cmp "$fixture/expected-settings" "$CLAUDE_TEST_DEST/settings.json"
cmp "$fixture/expected-learning" "$CLAUDE_TEST_DEST/skills/example skill/learnings.md"
cmp "$source_dir/skills/example skill/nested path/file name.md" \
  "$CLAUDE_TEST_DEST/skills/example skill/nested path/file name.md"
assert_clean_tmp
echo 'PASS: successful install, nested/space/symlinked skills, repeat install, local state, cleanup'

mkdir -p "$fixture/copy-bin"
cat > "$fixture/copy-bin/cp" <<'EOF'
#!/bin/sh
for destination do :; done
printf 'partial copy\n' > "$destination"
echo 'forced copy failure' >&2
exit 23
EOF
chmod +x "$fixture/copy-bin/cp"

assert_referent_unchanged() {
  case "$kind" in
    live) printf 'original referent\n' | cmp - "$referent" ;;
    dangling) [ ! -e "$referent" ] ;;
    directory)
      printf 'directory contents\n' | cmp - "$referent/sentinel"
      [ "$(ls -A "$referent")" = sentinel ]
      ;;
  esac
}

for kind in live dangling directory; do
  CLAUDE_TEST_DEST="$fixture/link-$kind"
  referent="$fixture/referent-$kind"
  mkdir -p "$CLAUDE_TEST_DEST"
  case "$kind" in
    live) printf 'original referent\n' > "$referent" ;;
    directory)
      mkdir "$referent"
      printf 'directory contents\n' > "$referent/sentinel"
      ;;
  esac
  ln -s "$referent" "$CLAUDE_TEST_DEST/CLAUDE.md"

  status=0
  PATH="$fixture/copy-bin:$PATH" sh "$install_script" \
    > "$fixture/link-$kind-failure.log" 2>&1 || status=$?
  if [ "$status" -ne 23 ]; then
    echo "expected copy status 23 for $kind link; got $status" >&2
    cat "$fixture/link-$kind-failure.log" >&2
    exit 1
  fi
  [ -L "$CLAUDE_TEST_DEST/CLAUDE.md" ]
  [ "$(readlink "$CLAUDE_TEST_DEST/CLAUDE.md")" = "$referent" ]
  [ ! -e "$CLAUDE_TEST_DEST/settings.json" ]
  assert_referent_unchanged
  assert_clean_tmp

  sh "$install_script" > "$fixture/link-$kind-success.log" 2>&1 || {
    cat "$fixture/link-$kind-success.log" >&2
    exit 1
  }
  [ ! -L "$CLAUDE_TEST_DEST/CLAUDE.md" ]
  cmp "$source_dir/CLAUDE.md" "$CLAUDE_TEST_DEST/CLAUDE.md"
  assert_referent_unchanged
  assert_clean_tmp
  echo "PASS: $kind symlink survives copy failure, migrates successfully, referent unchanged, cleanup"
done

cat > "$fixture/bin/find" <<'EOF'
#!/bin/sh
[ "$1" = -H ] && shift
if [ "$CLAUDE_TEST_FIND_MODE" = partial ]; then
  printf '%s/SKILL.md\n' "$1"
fi
echo 'forced find traversal failure' >&2
exit 17
EOF
chmod +x "$fixture/bin/find"

for mode in empty partial; do
  CLAUDE_TEST_DEST="$fixture/failure-$mode"
  status=0
  PATH="$fixture/bin:$PATH" CLAUDE_TEST_FIND_MODE="$mode" \
    sh "$install_script" > "$fixture/failure-$mode.log" 2>&1 || status=$?
  if [ "$status" -ne 17 ]; then
    echo "expected find status 17 for $mode output; got $status" >&2
    cat "$fixture/failure-$mode.log" >&2
    exit 1
  fi
  [ ! -e "$CLAUDE_TEST_DEST/settings.json" ]
  [ ! -e "$CLAUDE_TEST_DEST/skills/example skill/SKILL.md" ]
  assert_clean_tmp
  echo "PASS: find failure with $mode output exits 17, skips skill/settings, cleans up"
done
