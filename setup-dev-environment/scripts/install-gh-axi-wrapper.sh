#!/usr/bin/env bash
# Install gh-axi-wrapper.sh as $GROK_HOME/bin/gh-axi (ahead of npm on Grok PATH).
# Usage: install-gh-axi-wrapper.sh
set -euo pipefail

usage() {
  cat <<'EOF'
Usage: install-gh-axi-wrapper.sh

Copies gh-axi-wrapper.sh to $GROK_HOME/bin/gh-axi so Grok sessions pick it up
before the npm gh-axi. See gh-axi-wrapper.sh for why.

Environment:
  GROK_HOME   Grok config home (default: ~/.grok)
EOF
}

if [[ "${1:-}" == -h || "${1:-}" == --help ]]; then
  usage
  exit 0
fi

script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
src=$script_dir/gh-axi-wrapper.sh
if [[ ! -f "$src" ]]; then
  echo "error: missing $src" >&2
  exit 1
fi

grok_home=${GROK_HOME:-$HOME/.grok}
dest_dir=$grok_home/bin
dest=$dest_dir/gh-axi
mkdir -p "$dest_dir"
install -m 0755 "$src" "$dest"
echo "installed gh-axi wrapper -> $dest"
