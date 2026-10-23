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
test -s "$repo_root/Anet_ET4_Config_files/klipper-configs/display-et4.cfg"
grep -Fq '[board_pins et4_display]' "$repo_root/Anet_ET4_Config_files/klipper-configs/display-et4.cfg"
test -s "$repo_root/Anet_ET4_Config_files/klipper-configs/overrides/klipper-macros-adaptive-mesh.patch"
grep -Fq '_KM_BED_MESH_CALIBRATE_BASE ADAPTIVE=1' "$repo_root/Anet_ET4_Config_files/klipper-configs/overrides/klipper-macros-adaptive-mesh.patch"
if grep -Fq 'adaptive-mesh.cfg' "$repo_root/Anet_ET4_Config_files/printer.cfg"; then
    echo "Do not include the failed rename_existing adaptive mesh override." >&2
    exit 1
fi
grep -Fq 'MESH_MIN={initial_layer_bb_min_x},{initial_layer_bb_min_y}' "$repo_root/examples/cura-5.14-machine-start.gcode"
grep -Fq 'MESH_MAX={initial_layer_bb_max_x},{initial_layer_bb_max_y}' "$repo_root/examples/cura-5.14-machine-start.gcode"
grep -Fq '_PRINT_START_PHASE_PURGE' "$repo_root/examples/cura-5.14-machine-start.gcode"
if grep -R -nE '/dev/ttyUSB[0-9]+' "$repo_root/Anet_ET4_Config_files"; then
    echo "A volatile ttyUSB path is committed." >&2
    exit 1
fi

for file in README.md docs/installation-debian-13-mini-pc.md docs/operations.md docs/recovery.md docs/hardware-safety.md docs/migration-from-raspberry-pi.md docs/validation-checklist.md; do
    test -s "$repo_root/$file"
done

grep -Fq '/dev/serial/by-id/' "$repo_root/docs/installation-debian-13-mini-pc.md"
grep -Fq 'Never heat' "$repo_root/docs/hardware-safety.md"
grep -Fq 'DRAW_PURGE_LINE' "$repo_root/docs/operations.md"
grep -Fq 'SMART_PARK' "$repo_root/docs/operations.md"

if grep -R -nE '(BEGIN( |_)?[A-Z ]*PRIVATE KEY|password[[:space:]]*=|PRIVATE_KEY)' --exclude-dir=.git "$repo_root/deploy" "$repo_root/scripts"; then
    echo "Potential secret found in deployment content." >&2
    exit 1
fi
