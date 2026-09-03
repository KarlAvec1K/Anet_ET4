#!/usr/bin/env bash
set -euo pipefail

printf '%s\n' '== Services =='
systemctl is-active klipper moonraker nginx nftables anet-et4-backup.timer 2>/dev/null || true
printf '%s\n' '== Persistent USB serial =='
ls -l /dev/serial/by-id 2>/dev/null || true
printf '%s\n' '== Moonraker =='
if command -v curl >/dev/null; then
    curl -fsS http://127.0.0.1:7125/server/info || true
    printf '\n'
    curl -fsS 'http://127.0.0.1:7125/printer/objects/query?extruder=target,temperature,power&heater_bed=target,temperature,power' || true
    printf '\n'
fi
