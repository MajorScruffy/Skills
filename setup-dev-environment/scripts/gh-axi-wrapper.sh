#!/usr/bin/env bash
# Shadow `gh-axi` so space-separated value flags are not stolen as positionals.
# gh-axi 0.1.30's `repo list` takes the first non-flag token as owner, and
# `--limit 100` therefore becomes `gh repo list 100` (GitHub user "100").
# Equals form (`--limit=100`) is parsed correctly; rewrite to that.
set -euo pipefail

self=$(readlink -f "$0")
real=""
old_ifs=$IFS
IFS=:
for dir in $PATH; do
  [[ -n "$dir" ]] || continue
  cand=$dir/gh-axi
  [[ -x "$cand" ]] || continue
  cand_real=$(readlink -f "$cand")
  if [[ "$cand_real" != "$self" ]]; then
    real=$cand
    break
  fi
done
IFS=$old_ifs

if [[ -z "$real" ]]; then
  echo "error: real gh-axi not found on PATH" >&2
  exit 127
fi

value_flags='|--limit|--visibility|--language|--state|--head|--jq|--hostname|--template|--description|--default-branch|'

out=()
i=0
args=("$@")
n=${#args[@]}
while (( i < n )); do
  arg=${args[$i]}
  if [[ "$value_flags" == *"|${arg}|"* ]] && (( i + 1 < n )); then
    next=${args[$((i + 1))]}
    if [[ "$next" != -* ]]; then
      out+=("${arg}=${next}")
      i=$((i + 2))
      continue
    fi
  fi
  out+=("$arg")
  i=$((i + 1))
done

exec "$real" "${out[@]}"
