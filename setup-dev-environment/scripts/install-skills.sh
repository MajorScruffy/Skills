#!/usr/bin/env bash
# Copy every skill directory from this catalog into Grok and Cursor skill homes.
# Usage: install-skills.sh
# Catalog: $SKILLS_ROOT, else this script's git toplevel, else $PWD if it
# contains this script, else $HOME/Work/Skills.
set -euo pipefail

usage() {
  cat <<'EOF'
Usage: install-skills.sh

Copies each skill folder (a directory containing SKILL.md) from the Skills
catalog into $GROK_HOME/skills (default ~/.grok/skills) and
$CURSOR_HOME/skills (default ~/.cursor/skills). Replaces an existing
directory or symlink of the same name. Leaves other names in each
destination untouched.

Environment:
  GROK_HOME     Grok config home (default: ~/.grok)
  CURSOR_HOME   Cursor config home (default: ~/.cursor)
  SKILLS_ROOT   Catalog git clone (optional)
EOF
}

if [[ "${1:-}" == -h || "${1:-}" == --help ]]; then
  usage
  exit 0
fi

script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

looks_like_catalog() {
  local root=$1
  [[ -f "$root/setup-dev-environment/scripts/install-skills.sh" ]]
}

resolve_catalog() {
  local root
  if [[ -n "${SKILLS_ROOT:-}" ]]; then
    printf '%s\n' "$SKILLS_ROOT"
    return
  fi
  if root=$(git -C "$script_dir" rev-parse --show-toplevel 2>/dev/null) && looks_like_catalog "$root"; then
    printf '%s\n' "$root"
    return
  fi
  if root=$(git -C "$PWD" rev-parse --show-toplevel 2>/dev/null) && looks_like_catalog "$root"; then
    printf '%s\n' "$root"
    return
  fi
  if looks_like_catalog "${HOME}/Work/Skills"; then
    printf '%s\n' "${HOME}/Work/Skills"
    return
  fi
  echo "error: cannot find the Skills catalog clone" >&2
  echo "Clone https://github.com/MajorScruffy/Skills.git and run this script from that repo, or set SKILLS_ROOT." >&2
  exit 1
}

copy_skills() {
  local dest=$1
  mkdir -p "$dest"
  dest=$(cd "$dest" && pwd)
  local copied=0
  local skill_dir name
  for skill_dir in "$catalog"/*/; do
    [[ -f "${skill_dir}SKILL.md" ]] || continue
    name=$(basename "$skill_dir")
    rm -rf "$dest/$name"
    cp -a "$catalog/$name" "$dest/$name"
    echo "installed $name -> $dest/$name"
    copied=$((copied + 1))
  done
  if [[ "$copied" -eq 0 ]]; then
    echo "error: no skill directories found in $catalog" >&2
    exit 1
  fi
  echo "copied $copied skills to $dest"
}

catalog=$(resolve_catalog)
catalog=$(cd "$catalog" && pwd)

grok_home=$(cd "${GROK_HOME:-$HOME/.grok}" && pwd)
copy_skills "$grok_home/skills"

cursor_home=${CURSOR_HOME:-$HOME/.cursor}
mkdir -p "$cursor_home"
cursor_home=$(cd "$cursor_home" && pwd)
copy_skills "$cursor_home/skills"
