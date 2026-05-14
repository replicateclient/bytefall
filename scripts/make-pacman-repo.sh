#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
repo_dir="$repo_root/repo/x86_64"
repo_name="bytefall"

mkdir -p "$repo_dir"

if ! command -v repo-add >/dev/null 2>&1; then
  echo "repo-add not found. Install pacman-contrib on Arch Linux." >&2
  exit 1
fi

shopt -s nullglob
packages=("$repo_dir"/*.pkg.tar.*)
if (( ${#packages[@]} == 0 )); then
  echo "No packages found in $repo_dir"
  exit 0
fi

repo-add "$repo_dir/$repo_name.db.tar.gz" "${packages[@]}"

