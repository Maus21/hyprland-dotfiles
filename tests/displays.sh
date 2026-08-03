#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
test_root="$(mktemp -d)"
trap 'rm -rf -- "$test_root"' EXIT
mkdir -p "$test_root/bin"

cat >"$test_root/bin/hyprctl" <<'EOF'
#!/usr/bin/env bash
if [ "${1:-}" = monitors ]; then
  cat "$MONITOR_FIXTURE"
fi
EOF
chmod +x "$test_root/bin/hyprctl"

dual_home="$test_root/dual-home"
PATH="$test_root/bin:$PATH" MONITOR_FIXTURE="$repo_root/tests/fixtures/monitors-dual.json" \
  DOTFILES_TARGET_HOME="$dual_home" "$repo_root/scripts/configure-displays" >/dev/null
dual_config="$dual_home/.config/hypr/hardware.lua"
rg -q 'workspace = "1", monitor = "DP-3"' "$dual_config"
rg -q 'workspace = "6", monitor = "eDP-1"' "$dual_config"
rg -q 'xrandr --output DP-3 --primary' "$dual_config"

single_home="$test_root/single-home"
PATH="$test_root/bin:$PATH" MONITOR_FIXTURE="$repo_root/tests/fixtures/monitors-single.json" \
  DOTFILES_TARGET_HOME="$single_home" "$repo_root/scripts/configure-displays" >/dev/null
single_config="$single_home/.config/hypr/hardware.lua"
rg -q 'workspace = "1", monitor = "eDP-2"' "$single_config"
rg -q 'workspace = "10", monitor = "eDP-2"' "$single_config"
rg -q 'xrandr --output eDP-2 --primary' "$single_config"

printf 'Display fixture tests passed.\n'
