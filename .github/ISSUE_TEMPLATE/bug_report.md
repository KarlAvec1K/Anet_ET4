---
name: Bug report
about: Report an Anet ET4 Debian mini-PC deployment issue
title: ''
labels: ''
assignees: ''
---

## Safety first

Do not attach passwords, private keys, public IP addresses, or private G-code.
State whether heaters and motors were physically safe and idle. Do not perform a
movement or heating test solely to collect this report.

## Problem

Describe the expected and observed behavior.

## Host

- Debian version and kernel:
- Mini-PC model:
- Service account:
- Mainsail browser and version:
- Klipper, Moonraker, and Mainsail versions:

## Printer and USB

- Printer board revision:
- USB device shown by `lsusb`:
- Persistent path shown by `ls -l /dev/serial/by-id/`:
- Klipper state from `bash install.sh --status`:
- Passive extruder and bed temperatures, with targets:

## Reproduction

List safe, repeatable steps. Include whether the issue survives a service restart
or controlled mini-PC reboot.

## Logs

Attach only the relevant sanitized output:

```bash
systemctl status klipper moonraker nginx --no-pager
journalctl -u klipper -n 150 --no-pager
journalctl -u moonraker -n 150 --no-pager
```
