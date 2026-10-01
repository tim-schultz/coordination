#!/bin/sh
# Checks install.sh against a fresh project and an existing one.
set -eu
here=$(cd "$(dirname "$0")" && pwd)
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
fail() { echo "FAIL: $*"; exit 1; }
count() { grep -cF "$1" "$2" || true; }

# Fresh project: everything is created.
fresh=$tmp/fresh
mkdir "$fresh"
"$here/install.sh" "$fresh" >/dev/null
for f in COORDINATION.md AGENTS.md CLAUDE.md coordination/archive/.gitkeep; do
  [ -e "$fresh/$f" ] || fail "fresh: missing $f"
done
grep -qx '@COORDINATION.md' "$fresh/CLAUDE.md" || fail "CLAUDE.md does not import COORDINATION.md"
grep -qF '](COORDINATION.md)' "$fresh/AGENTS.md" || fail "AGENTS.md does not link COORDINATION.md"
grep -qF '## Open threads' "$fresh/COORDINATION.md" || fail "COORDINATION.md has no thread table"
grep -rqE "docs/|plan|milestone|v4|every agent.s context" "$fresh" && fail "project-specific wording installed"

# Existing project: content is kept, rules are updated, re-runs do not duplicate.
old=$tmp/old
mkdir "$old"
printf '# Mine\n\nKeep this.\n' > "$old/CLAUDE.md"
printf '# Codex notes\n' > "$old/AGENTS.md"
"$here/install.sh" "$old" >/dev/null
echo '| X-1 | Codex | live | keep this row |' >> "$old/COORDINATION.md"
sed 's/Read before working/STALE RULE/' "$old/COORDINATION.md" > "$old/c" && mv "$old/c" "$old/COORDINATION.md"
"$here/install.sh" "$old" >/dev/null
"$here/install.sh" "$old" >/dev/null
grep -qF 'Keep this.' "$old/CLAUDE.md" || fail "existing CLAUDE.md content lost"
grep -qF '# Codex notes' "$old/AGENTS.md" || fail "existing AGENTS.md content lost"
grep -qF 'keep this row' "$old/COORDINATION.md" || fail "thread row lost"
grep -qF 'STALE RULE' "$old/COORDINATION.md" && fail "rules not updated"
for f in CLAUDE.md AGENTS.md COORDINATION.md; do
  [ "$(count '<!-- coordination:start -->' "$old/$f")" = 1 ] || fail "$f block duplicated"
done

# AGENTS.md symlinked to CLAUDE.md stays a link and gets one block serving both agents.
link=$tmp/link
mkdir "$link"
printf '# Shared\n' > "$link/CLAUDE.md"
ln -s CLAUDE.md "$link/AGENTS.md"
"$here/install.sh" "$link" >/dev/null
"$here/install.sh" "$link" >/dev/null
[ -L "$link/AGENTS.md" ] || fail "AGENTS.md symlink replaced"
[ "$(count '<!-- coordination:start -->' "$link/CLAUDE.md")" = 1 ] || fail "shared file block duplicated"
grep -qx '@COORDINATION.md' "$link/CLAUDE.md" || fail "shared file lost the Claude import"
grep -qF '](COORDINATION.md)' "$link/CLAUDE.md" || fail "shared file lost the Codex link"

# A COORDINATION.md without markers is refused and left untouched.
legacy=$tmp/legacy
mkdir "$legacy"
printf '# Old rules\n' > "$legacy/COORDINATION.md"
"$here/install.sh" "$legacy" >/dev/null 2>&1 && fail "unmarked COORDINATION.md accepted"
[ "$(cat "$legacy/COORDINATION.md")" = "# Old rules" ] || fail "unmarked COORDINATION.md modified"
echo PASS
