#!/usr/bin/env bash
set -euo pipefail

if (( EUID != 0 )); then
  printf 'Run this script with sudo to enable the internal Wi-Fi adapter.\n' >&2
  exit 1
fi

blacklist_file=/etc/modprobe.d/disable-internal-wifi.conf
disabled_file=/etc/modprobe.d/disable-internal-wifi.conf.disabled

if [[ -f "$blacklist_file" ]]; then
  if [[ -e "$disabled_file" ]]; then
    printf 'Existing backup needs review: %s\n' "$disabled_file" >&2
    exit 1
  fi
  if ! rg -q '^[[:space:]]*blacklist[[:space:]]+rtw88_8822ce[[:space:]]*$' "$blacklist_file" \
    || rg -v -q '^([[:space:]]*#.*|[[:space:]]*|[[:space:]]*blacklist[[:space:]]+rtw88_8822ce[[:space:]]*)$' "$blacklist_file"; then
    printf 'The Wi-Fi blacklist contains other settings; review it before moving it.\n' >&2
    exit 1
  fi
  mv -- "$blacklist_file" "$disabled_file"
fi

modprobe rtw88_8822ce
udevadm settle --timeout=10 || true

for network_device in /sys/class/net/*; do
  if [[ -d "$network_device/wireless" ]]; then
    printf 'Wi-Fi interface ready: %s\n' "${network_device##*/}"
    exit 0
  fi
done

printf 'The driver loaded, but no wireless interface appeared. Check kernel logs.\n' >&2
exit 1
