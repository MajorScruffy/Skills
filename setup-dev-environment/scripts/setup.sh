#!/usr/bin/env bash
# Bootstrap a Grok Build + Herdr firstmate home and install this skill catalog.
# Usage: setup.sh
set -euo pipefail

usage() {
  cat <<'EOF'
Usage: setup.sh

1. Copies this Skills catalog into $GROK_HOME/skills and $CURSOR_HOME/skills
   (see install-skills.sh).
2. Clones kunchenguid/firstmate into $FIRSTMATE_ROOT if missing.
3. Pins config/backend=herdr in that home (gitignored).
4. Installs missing firstmate toolchain: treehouse, no-mistakes, gh-axi,
   chrome-devtools-axi, lavish-axi, tasks-axi, quota-axi.
5. Installs a gh-axi PATH wrapper in $GROK_HOME/bin so `repo list --limit N`
   lists the authenticated account (gh-axi otherwise treats N as the owner).
6. Prints how to launch the captain: Herdr, then grok --trust in the clone.

Does not launch Grok or grant hook trust. Those need an interactive session.

Environment:
  GROK_HOME        Grok config home (default: ~/.grok)
  CURSOR_HOME      Cursor config home (default: ~/.cursor)
  SKILLS_ROOT      Skills catalog clone (optional; see install-skills.sh)
  WORK_DIR         Parent for the firstmate clone (default: ~/Work)
  FIRSTMATE_ROOT   Firstmate checkout (default: $WORK_DIR/firstmate)
EOF
}

if [[ "${1:-}" == -h || "${1:-}" == --help ]]; then
  usage
  exit 0
fi

script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
work_dir=${WORK_DIR:-$HOME/Work}
firstmate_root=${FIRSTMATE_ROOT:-$work_dir/firstmate}

echo "==> skills catalog"
"$script_dir/install-skills.sh"

echo "==> firstmate clone"
if [[ -d "$firstmate_root/.git" ]]; then
  echo "using existing $firstmate_root"
else
  mkdir -p "$(dirname "$firstmate_root")"
  git clone https://github.com/kunchenguid/firstmate.git "$firstmate_root"
fi

echo "==> herdr backend pin"
mkdir -p "$firstmate_root/config"
printf 'herdr\n' > "$firstmate_root/config/backend"
echo "wrote $firstmate_root/config/backend"

need() {
  command -v "$1" >/dev/null 2>&1
}

echo "==> toolchain"
if ! need git || ! need gh || ! need jq || ! need node || ! need grok || ! need herdr; then
  echo "error: git, gh, jq, node, grok, and herdr must already be on PATH" >&2
  exit 1
fi
if ! gh auth status >/dev/null 2>&1; then
  echo "error: GitHub CLI is not authenticated; run: gh auth login" >&2
  exit 1
fi

if ! need treehouse; then
  echo "installing treehouse"
  curl -fsSL https://kunchenguid.github.io/treehouse/install.sh | sh
fi
if ! need no-mistakes; then
  echo "installing no-mistakes"
  curl -fsSL https://raw.githubusercontent.com/kunchenguid/no-mistakes/main/docs/install.sh | sh
fi
for pkg in gh-axi chrome-devtools-axi lavish-axi tasks-axi quota-axi; do
  if ! need "$pkg"; then
    echo "installing $pkg"
    npm install -g "$pkg"
    case "$pkg" in
      gh-axi|chrome-devtools-axi|lavish-axi)
        "$pkg" setup hooks
        ;;
    esac
  fi
done

echo "==> gh-axi wrapper"
"$script_dir/install-gh-axi-wrapper.sh"

echo "==> launch"
cat <<EOF
Captain is Grok Build. In Ghostty:

  herdr
  cd $firstmate_root
  grok --trust

--trust is required once per clone so firstmate's .grok/hooks load.
Talk only to that session; it spawns crew in Herdr tabs.
EOF
