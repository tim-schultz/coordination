#!/bin/sh
# Installs or updates Codex–Claude coordination in a project.
# Usage: install.sh [project-dir]   (defaults to the current directory)
# Re-running updates the marked blocks and keeps everything else.
set -eu
template=$(cd "$(dirname "$0")" && pwd)/template
project=${1:-.}
start='<!-- coordination:start -->'
end='<!-- coordination:end -->'

# put_block TARGET SOURCE: replace TARGET's marked block with SOURCE's, or append it.
# Writes in place so symlinked targets stay links.
put_block() {
  block=$(mktemp)
  out=$(mktemp)
  sed -n "/^$start\$/,/^$end\$/p" "$2" > "$block"
  if grep -qxF "$start" "$1"; then
    awk -v s="$start" -v e="$end" -v b="$block" '
      $0 == s { while ((getline l < b) > 0) print l; skip = 1; next }
      $0 == e { skip = 0; next }
      !skip' "$1" > "$out"
    cat "$out" > "$1"
  else
    [ -s "$1" ] && printf '\n' >> "$1"
    cat "$block" >> "$1"
  fi
  rm -f "$block" "$out"
}

coordination=$project/COORDINATION.md
if [ -e "$coordination" ] && ! grep -qxF "$start" "$coordination"; then
  echo "$coordination exists without coordination markers; merge it by hand." >&2
  exit 1
fi

mkdir -p "$project/coordination/archive"
touch "$project/coordination/archive/.gitkeep"

if [ -e "$coordination" ]; then
  put_block "$coordination" "$template/COORDINATION.md"
else
  cp "$template/COORDINATION.md" "$coordination"
fi

for f in CLAUDE.md AGENTS.md; do
  touch "$project/$f"
  put_block "$project/$f" "$template/pointer.md"
done

echo "Coordination installed in $(cd "$project" && pwd)"
