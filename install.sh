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
put_block() {
  block=$(mktemp)
  sed -n "/^$start\$/,/^$end\$/p" "$2" > "$block"
  if grep -qxF "$start" "$1"; then
    awk -v s="$start" -v e="$end" -v b="$block" '
      $0 == s { while ((getline l < b) > 0) print l; skip = 1; next }
      $0 == e { skip = 0; next }
      !skip' "$1" > "$1.tmp" && mv "$1.tmp" "$1"
  else
    [ -s "$1" ] && printf '\n' >> "$1"
    cat "$block" >> "$1"
  fi
  rm -f "$block"
}

mkdir -p "$project/coordination" "$project/docs/archive/coordination"
touch "$project/coordination/.gitkeep" "$project/docs/archive/coordination/.gitkeep"

if [ -e "$project/COORDINATION.md" ]; then
  put_block "$project/COORDINATION.md" "$template/COORDINATION.md"
else
  cp "$template/COORDINATION.md" "$project/COORDINATION.md"
fi

for f in CLAUDE.md AGENTS.md; do
  touch "$project/$f"
  put_block "$project/$f" "$template/$f"
done

echo "Coordination installed in $(cd "$project" && pwd)"
