#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
test_home="$(mktemp -d)"
trap 'rm -rf -- "$test_home"' EXIT

mkdir -p \
  "$test_home/.config/hypr" \
  "$test_home/.config/kitty" \
  "$test_home/.config/gtk-3.0" \
  "$test_home/.config/gtk-4.0" \
  "$test_home/.local/bin"

cp -a "$repo_root/home/.config/hypr/themes" "$test_home/.config/hypr/themes"
cp -- "$repo_root/home/.local/bin/hypr-theme-switcher" \
  "$test_home/.local/bin/hypr-theme-switcher"

HOME="$test_home" "$test_home/.local/bin/hypr-theme-switcher" apply noir >/dev/null

cmp -s \
  "$repo_root/home/.config/kitty/theme-current.conf" \
  "$test_home/.config/kitty/theme-current.conf"
cmp -s \
  "$repo_root/home/.config/gtk-3.0/colors.css" \
  "$test_home/.config/gtk-3.0/colors.css"
cmp -s \
  "$repo_root/home/.config/gtk-4.0/colors.css" \
  "$test_home/.config/gtk-4.0/colors.css"

printf 'Noir theme generation test passed.\n'
