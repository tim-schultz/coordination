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
for f in COORDINATION.md AGENTS.md CLAUDE.md coordination/.gitkeep docs/archive/coordination/.gitkeep; do
  [ -e "$fresh/$f" ] || fail "fresh: missing $f"
done
grep -qx '@COORDINATION.md' "$fresh/CLAUDE.md" || fail "CLAUDE.md does not import COORDINATION.md"
grep -qF '](COORDINATION.md)' "$fresh/AGENTS.md" || fail "AGENTS.md does not link COORDINATION.md"
grep -qF '## Open threads' "$fresh/COORDINATION.md" || fail "COORDINATION.md has no thread table"

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
echo PASS
