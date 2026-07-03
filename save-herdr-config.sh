#!/usr/bin/env bash
# Copy the live herdr config (edited via its UI) back into this repo so it can
# be committed. Counterpart to the home.activation.herdrConfig seed step.
set -euo pipefail

repo_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Herdr config.toml
src="$HOME/.config/herdr/config.toml"
dst="$repo_dir/modules/home-manager/files/herdr/config.toml"
if [ ! -f "$src" ]; then
  echo "error: $src not found" >&2
  exit 1
fi
cp -f "$src" "$dst"
echo "Saved $src -> $dst"

# Herdr Picker Plus config.toml
src2="$HOME/.config/herdr/plugins/config/herdr-picker-plus/config.toml"
dst2="$repo_dir/modules/home-manager/files/herdr-plugins/picker-plus/config.toml"
if [ ! -f "$src2" ]; then
  echo "warning: $src2 not found (picker-plus config not yet created)" >&2
else
  cp -f "$src2" "$dst2"
  echo "Saved $src2 -> $dst2"
fi

echo "Review with 'git diff' and commit when ready."
