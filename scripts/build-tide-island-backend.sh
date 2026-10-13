#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source_archive="${1:-$HOME/.cache/yay/tide-island/tide-island-1.0.41.tar.xz}"
target_home="${DOTFILES_TARGET_HOME:-$HOME}"
work_dir="$(mktemp -d)"
trap 'find "$work_dir" -depth -delete' EXIT

if [[ "$(pacman -Q tide-island 2>/dev/null)" != "tide-island 1.0.41-1" ]]; then
  printf 'This patch is for tide-island 1.0.41-1 only.\n' >&2
  exit 1
fi
if [[ ! -f "$source_archive" ]]; then
  printf 'Tide Island source archive is missing: %s\n' "$source_archive" >&2
  exit 1
fi

tar -xf "$source_archive" -C "$work_dir"
source_dir="$work_dir/Tide-island-1.0.41"
patch -s -F0 -d "$source_dir" -p1 < "$repo_root/patches/tide-island-1.0.41-singletons.patch"
cmake -S "$source_dir" -B "$work_dir/build" -DCMAKE_BUILD_TYPE=Release -DTIDE_ISLAND_WITH_NIRI=ON
cmake --build "$work_dir/build" --target IslandBackend -j 4
install -Dm755 "$work_dir/build/libIslandBackend.so" "$target_home/.local/lib/libIslandBackend.so"
printf 'Installed patched Tide Island backend at %s\n' "$target_home/.local/lib/libIslandBackend.so"
