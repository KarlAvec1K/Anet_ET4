#!/usr/bin/env bash
set -euo pipefail

repo_root=$(cd "$(dirname "$0")/.." && pwd)

test -d "$repo_root/deploy/debian"
test -s "$repo_root/deploy/debian/systemd/klipper.service.in"
test -s "$repo_root/deploy/debian/systemd/moonraker.service.in"
test -s "$repo_root/deploy/debian/moonraker/moonraker.conf.in"
test -s "$repo_root/deploy/debian/nginx/mainsail.conf.in"
test -s "$repo_root/deploy/debian/nftables/nftables.conf.in"

grep -Fq 'host: 127.0.0.1' "$repo_root/deploy/debian/moonraker/moonraker.conf.in"
grep -Fq 'Restart=always' "$repo_root/deploy/debian/systemd/klipper.service.in"
grep -Fq 'ip saddr __TRUSTED_LAN_CIDR__ tcp dport { 22, 80 } accept' "$repo_root/deploy/debian/nftables/nftables.conf.in"

grep -Fq '[mcu]' "$repo_root/Anet_ET4_Config_files/klipper-configs/Micro-controller.cfg"
grep -Fq 'serial: /dev/serial/by-id/' "$repo_root/Anet_ET4_Config_files/klipper-configs/Micro-controller.cfg"
if grep -R -nE '/dev/ttyUSB[0-9]+' "$repo_root/Anet_ET4_Config_files"; then
    echo "A volatile ttyUSB path is committed." >&2
    exit 1
fi

for file in README.md docs/installation-debian-13-mini-pc.md docs/operations.md docs/recovery.md docs/hardware-safety.md docs/migration-from-raspberry-pi.md docs/validation-checklist.md; do
    test -s "$repo_root/$file"
done

grep -Fq '/dev/serial/by-id/' "$repo_root/docs/installation-debian-13-mini-pc.md"
grep -Fq 'Never heat' "$repo_root/docs/hardware-safety.md"

if grep -R -nE '(BEGIN( |_)?[A-Z ]*PRIVATE KEY|password[[:space:]]*=|PRIVATE_KEY)' --exclude-dir=.git "$repo_root/deploy" "$repo_root/scripts"; then
    echo "Potential secret found in deployment content." >&2
    exit 1
fi
