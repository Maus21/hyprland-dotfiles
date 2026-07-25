#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
test_home="$(mktemp -d)"
trap 'rm -rf -- "$test_home"' EXIT

mkdir -p "$test_home/.config/kitty"
printf 'unmanaged\n' >"$test_home/.config/kitty/kitty.conf"

DOTFILES_TARGET_HOME="$test_home" "$repo_root/install.sh" --skip-packages --skip-services >/dev/null
backup_count="$(find "$test_home/.dotfiles-backups" -type f | wc -l)"
test "$backup_count" -eq 1
DOTFILES_TARGET_HOME="$test_home" "$repo_root/install.sh" --skip-packages --skip-services >/dev/null
test "$(find "$test_home/.dotfiles-backups" -type f | wc -l)" -eq "$backup_count"

test -L "$test_home/.config/hypr/hyprland.lua"
test -L "$test_home/.config/hypr/themes/noir.theme"
test -L "$test_home/.config/fish/config.fish"
test -L "$test_home/.local/share/anifetch-cat.gif"
test -L "$test_home/.local/share/applications/bluetui.desktop"
test -L "$test_home/.local/share/applications/nmtui.desktop"
test -f "$test_home/.config/tide-island/userconfig.json"
test -f "$test_home/.config/systemd/user/tide-island-dotfiles.service"
rg -qF "$test_home/Pictures/wallpapers" "$test_home/.config/tide-island/userconfig.json"
! rg -q '/home/' "$test_home/.config/tide-island/userconfig.json"
rg -qx 'helium-browser-bin' "$repo_root/packages/pacman.txt"
rg -q '^nngceckbapebfimnlniiiahkandclblb' "$repo_root/packages/browser-extensions.tsv"
rg -q 'duckduckgo.com' "$repo_root/home/.local/share/tide-island-dotfiles/qml/island/WebSearchLayer.qml"
! rg -n -i '\brofi\b' \
  "$repo_root/home/.config/hypr" \
  "$repo_root/home/.local/bin" \
  "$repo_root/home/.local/share/tide-island-dotfiles" \
  "$repo_root/packages" \
  "$repo_root/README.md"

dry_home="$(mktemp -d)"
DOTFILES_TARGET_HOME="$dry_home" "$repo_root/install.sh" --dry-run --skip-packages --skip-services >/dev/null
test -z "$(find "$dry_home" -mindepth 1 -print -quit)"
rmdir "$dry_home"

printf 'Smoke test passed for %s\n' "$test_home"
