#!/usr/bin/env bash
set -euo pipefail

printf '%s\n' '== Operating system =='
hostnamectl 2>/dev/null || uname -a
printf '%s\n' '== CPU, memory, storage =='
lscpu 2>/dev/null || true
free -h 2>/dev/null || true
df -h / 2>/dev/null || true
sensors 2>/dev/null || true
printf '%s\n' '== Network =='
hostname
ip -brief address 2>/dev/null || true
ip route 2>/dev/null || true
ss -ltn 2>/dev/null || true
timedatectl status 2>/dev/null || true
printf '%s\n' '== USB and persistent serial links =='
lsusb 2>/dev/null || true
ls -l /dev/serial/by-id 2>/dev/null || true
printf '%s\n' '== Services =='
systemctl --no-pager --plain is-active klipper moonraker nginx nftables anet-et4-backup.timer 2>/dev/null || true
systemctl --failed --no-pager 2>/dev/null || true
printf '%s\n' '== Repository =='
git -C "$(cd "$(dirname "$0")/.." && pwd)" status --short --branch 2>/dev/null || true
