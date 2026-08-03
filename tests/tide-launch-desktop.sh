#!/usr/bin/env bash
set -euo pipefail

launcher="${1:-}"
[ -x "$launcher" ] || exit 2

test_dir="$(mktemp -d)"
trap 'rm -rf "$test_dir"' EXIT
mkdir -p "$test_dir/bin"

cat > "$test_dir/bin/switcherooctl" <<'EOF'
#!/usr/bin/env bash
if [ "${1:-}" = "list" ]; then
  exit 0
fi
exit 99
EOF

cat > "$test_dir/bin/prime-run" <<'EOF'
#!/usr/bin/env bash
export TIDE_TEST_GPU=prime-run
exec "$@"
EOF

cat > "$test_dir/bin/gtk-launch" <<'EOF'
#!/usr/bin/env bash
printf '%s|%s\n' "${TIDE_TEST_GPU:-default}" "$1" > "$TIDE_TEST_OUTPUT"
EOF

chmod +x "$test_dir/bin/switcherooctl" "$test_dir/bin/prime-run" "$test_dir/bin/gtk-launch"

cat > "$test_dir/gpu-test.desktop" <<'EOF'
[Desktop Entry]
Type=Application
Name=GPU test
Terminal=false
PrefersNonDefaultGPU=true
Exec=true
EOF

PATH="$test_dir/bin:$PATH" TIDE_TEST_OUTPUT="$test_dir/result" \
  "$launcher" "$test_dir/gpu-test.desktop"
test "$(cat "$test_dir/result")" = "prime-run|gpu-test"

cat > "$test_dir/default-test.desktop" <<'EOF'
[Desktop Entry]
Type=Application
Name=Default test
Terminal=false
Exec=true
EOF

PATH="$test_dir/bin:$PATH" TIDE_TEST_OUTPUT="$test_dir/result" \
  "$launcher" "$test_dir/default-test.desktop"
test "$(cat "$test_dir/result")" = "default|default-test"

printf 'Tide desktop launcher GPU tests passed\n'
