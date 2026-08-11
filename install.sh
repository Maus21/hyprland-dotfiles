#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
target_home="${DOTFILES_TARGET_HOME:-$HOME}"
dry_run=false
skip_packages=false
skip_services=false
skip_rishot=false

usage() {
  cat <<'EOF'
Usage: ./install.sh [--dry-run] [--skip-packages] [--skip-services] [--skip-rishot]

Environment:
  DOTFILES_TARGET_HOME  Install into another home (useful for testing).
EOF
}

while [ "$#" -gt 0 ]; do
  case "$1" in
    --dry-run) dry_run=true ;;
    --skip-packages) skip_packages=true ;;
    --skip-services) skip_services=true ;;
    --skip-rishot) skip_rishot=true ;;
    -h|--help) usage; exit 0 ;;
    *) printf 'Unknown option: %s\n' "$1" >&2; usage >&2; exit 2 ;;
  esac
  shift
done

if [ -r /etc/os-release ]; then
  # shellcheck disable=SC1091
  . /etc/os-release
  case "${ID:-}" in
    cachyos|arch) ;;
    *) printf 'Warning: designed for CachyOS/Arch; detected %s.\n' "${ID:-unknown}" >&2 ;;
  esac
fi

timestamp="$(date +%Y%m%d-%H%M%S)"
backup_root="$target_home/.dotfiles-backups/$timestamp"

if head -n 1 "$repo_root/home/.local/share/anifetch-cat.gif" 2>/dev/null | \
  grep -qF 'version https://git-lfs.github.com/spec/v1'; then
  printf 'Git LFS assets are pointers, not downloaded files. Run: git lfs pull\n' >&2
  exit 1
fi

say_run() {
  printf '+ '
  printf '%q ' "$@"
  printf '\n'
  if ! $dry_run; then
    "$@"
  fi
}

bootstrap_yay() {
  if command -v yay >/dev/null 2>&1; then
    return
  fi
  if $dry_run; then
    printf '+ bootstrap yay from the AUR\n'
    return
  fi
  sudo pacman -S --needed --noconfirm base-devel git
  local build_dir
  build_dir="$(mktemp -d)"
  git clone https://aur.archlinux.org/yay.git "$build_dir/yay"
  (cd "$build_dir/yay" && makepkg -si --needed --noconfirm)
  rm -rf -- "$build_dir"
}

install_packages() {
  local declared_packages=()
  local required_packages=()
  local optional_packages=()
  local package_name

  mapfile -t declared_packages < <(sed -e '/^[[:space:]]*#/d' -e '/^[[:space:]]*$/d' \
    "$repo_root/packages/pacman.txt" "$repo_root/packages/aur.txt")

  for package_name in "${declared_packages[@]}"; do
    if pacman -Q "$package_name" >/dev/null 2>&1; then
      continue
    fi

    case "$package_name" in
      cava|github-cli|hyprsunset) optional_packages+=("$package_name") ;;
      *) required_packages+=("$package_name") ;;
    esac
  done

  if [ "${#required_packages[@]}" -eq 0 ] && [ "${#optional_packages[@]}" -eq 0 ]; then
    printf 'All declared packages are already installed.\n'
    return
  fi

  bootstrap_yay

  if [ "${#required_packages[@]}" -gt 0 ]; then
    say_run yay -S --needed --noconfirm "${required_packages[@]}"
  fi

  for package_name in "${optional_packages[@]}"; do
    if ! say_run yay -S --needed --noconfirm "$package_name"; then
      printf 'Warning: optional package %s could not be installed; continuing.\n' "$package_name" >&2
    fi
  done
}

verify_required_commands() {
  local command_name
  local missing=()
  local required_commands=(
    awww brightnessctl easyeffects helium-browser jq kitty magick playerctl
    powerprofilesctl python3 qalc quickshell tide-island wl-copy wpctl xrandr yazi
  )

  if ! $skip_rishot; then
    required_commands+=(rishot)
  fi

  for command_name in "${required_commands[@]}"; do
    if ! command -v "$command_name" >/dev/null 2>&1; then
      missing+=("$command_name")
    fi
  done

  if [ "${#missing[@]}" -eq 0 ]; then
    return
  fi

  printf 'Missing required desktop commands: %s\n' "${missing[*]}" >&2
  if $skip_packages; then
    printf 'Warning: --skip-packages was used; install the missing dependencies before logging in.\n' >&2
    return
  fi

  printf 'The package stage did not provide every required command; refusing to report a complete install.\n' >&2
  exit 1
}

backup_destination() {
  local destination="$1"
  local relative="$2"
  if [ -e "$destination" ] || [ -L "$destination" ]; then
    say_run mkdir -p "$backup_root/$(dirname "$relative")"
    say_run mv -- "$destination" "$backup_root/$relative"
  fi
}

link_home() {
  local source relative destination source_real destination_real
  while IFS= read -r -d '' source; do
    relative="${source#"$repo_root/home/"}"
    destination="$target_home/$relative"
    if [ -L "$destination" ]; then
      if [ "$(readlink -- "$destination")" = "$source" ]; then
        continue
      fi
      source_real="$(readlink -f -- "$source" 2>/dev/null || true)"
      destination_real="$(readlink -f -- "$destination" 2>/dev/null || true)"
      if [ -n "$source_real" ] && [ "$source_real" = "$destination_real" ]; then
        continue
      fi
    fi
    backup_destination "$destination" "$relative"
    say_run mkdir -p "$(dirname "$destination")"
    say_run ln -s -- "$source" "$destination"
  done < <(find "$repo_root/home" \( -type f -o -type l \) -print0)
}

install_rishot() {
  local rishot_root="$target_home/.local/share/rishot"
  local rishot_repo="https://github.com/Gakuseei/rishot.git"
  local link_path link_target relative

  if [ -d "$rishot_root/.git" ]; then
    printf 'Preserving existing rishot checkout: %s\n' "$rishot_root"
  else
    if [ -e "$rishot_root" ] || [ -L "$rishot_root" ]; then
      backup_destination "$rishot_root" ".local/share/rishot"
    fi
    say_run mkdir -p "$(dirname "$rishot_root")"
    say_run git clone --depth 1 "$rishot_repo" "$rishot_root"
  fi

  while IFS='|' read -r link_path link_target; do
    relative="${link_path#"$target_home/"}"
    if [ -L "$link_path" ] && [ "$(readlink -- "$link_path")" = "$link_target" ]; then
      continue
    fi
    backup_destination "$link_path" "$relative"
    say_run mkdir -p "$(dirname "$link_path")"
    say_run ln -s -- "$link_target" "$link_path"
  done <<EOF
$target_home/.local/bin/rishot|$rishot_root/bin/rishot
$target_home/.local/share/applications/rishot.desktop|$rishot_root/rishot.desktop
$target_home/.local/share/icons/hicolor/scalable/apps/rishot.svg|$rishot_root/packaging/rishot.svg
EOF
}

render_templates() {
  local tide_config="$target_home/.config/tide-island/userconfig.json"
  local tide_marker="$target_home/.config/tide-island/.dotfiles-managed"
  local service="$target_home/.config/systemd/user/tide-island-dotfiles.service"
  local escaped_home
  escaped_home="${target_home//&/\\&}"

  if [ ! -e "$tide_marker" ]; then
    backup_destination "$tide_config" ".config/tide-island/userconfig.json"
    say_run mkdir -p "$(dirname "$tide_config")"
    if $dry_run; then
      printf '+ render %q -> %q\n' "$repo_root/templates/tide-userconfig.json" "$tide_config"
      printf '+ mark %q as locally managed\n' "$tide_config"
    else
      sed "s|__HOME__|$escaped_home|g" "$repo_root/templates/tide-userconfig.json" >"$tide_config"
      : >"$tide_marker"
    fi
  else
    printf 'Preserving locally managed Tide settings: %s\n' "$tide_config"
  fi

  if [ -f "$service" ] && cmp -s "$repo_root/templates/tide-island.service" "$service"; then
    printf 'Service already current: %s\n' "$service"
  else
    backup_destination "$service" ".config/systemd/user/tide-island-dotfiles.service"
    say_run mkdir -p "$(dirname "$service")"
    say_run cp -- "$repo_root/templates/tide-island.service" "$service"
  fi
}

post_install() {
  if [ "$target_home" = "$HOME" ] && command -v fc-cache >/dev/null 2>&1; then
    say_run fc-cache -f
  fi
  if [ "$target_home" = "$HOME" ] && command -v update-desktop-database >/dev/null 2>&1; then
    say_run update-desktop-database "$target_home/.local/share/applications"
  fi
  if ! $skip_services && [ "$target_home" = "$HOME" ] && command -v systemctl >/dev/null 2>&1; then
    say_run systemctl --user daemon-reload
    if [ -e "$target_home/.config/systemd/user/tide-island.service" ] \
      || [ -e /usr/lib/systemd/user/tide-island.service ]; then
      say_run systemctl --user disable --now tide-island.service
    fi
    if [ -e "$target_home/.config/systemd/user/tide-island-lorenzo.service" ]; then
      say_run systemctl --user disable --now tide-island-lorenzo.service
    fi
    say_run systemctl --user enable tide-island-dotfiles.service
    if [ -n "${HYPRLAND_INSTANCE_SIGNATURE:-}" ]; then
      say_run systemctl --user import-environment HYPRLAND_INSTANCE_SIGNATURE WAYLAND_DISPLAY
      say_run systemctl --user restart tide-island-dotfiles.service
    else
      say_run systemctl --user start tide-island-dotfiles.service
    fi
  fi
}

if ! $skip_packages; then
  install_packages
fi
link_home
render_templates
if ! $skip_rishot; then
  install_rishot
fi
if ! $dry_run && [ "$target_home" = "$HOME" ]; then
  verify_required_commands
fi
post_install

printf '\nInstall complete.\n'
printf 'Backups (if any): %s\n' "$backup_root"
if [ -n "${HYPRLAND_INSTANCE_SIGNATURE:-}" ] && [ "$target_home" = "$HOME" ]; then
  printf 'Generate the adaptive monitor profile with: %s/scripts/configure-displays\n' "$repo_root"
else
  printf 'After starting Hyprland, run: %s/scripts/configure-displays\n' "$repo_root"
fi
printf 'To make Fish your login shell: chsh -s /usr/bin/fish\n'
