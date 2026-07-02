#!/usr/bin/env bash
# Copy the live herdr config (edited via its UI) back into this repo so it can
# be committed. Counterpart to the home.activation.herdrConfig seed step.
set -euo pipefail

src="$HOME/.config/herdr/config.toml"
repo_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
dst="$repo_dir/modules/home-manager/files/herdr/config.toml"

if [ ! -f "$src" ]; then
  echo "error: $src not found" >&2
  exit 1
fi

cp -f "$src" "$dst"
echo "Saved $src -> $dst"
echo "Review with 'git diff' and commit when ready."
