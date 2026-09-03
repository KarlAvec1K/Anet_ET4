# Anet ET4 on Debian 13 Mini-PC

Reference deployment for a stock Anet ET4 with Klipper, Moonraker, and Mainsail on a headless Debian 13 mini-PC.

## What this repository provides

- Validated ET4-MB v1.1 Klipper configuration using a persistent USB serial path.
- A safe Bash installer for Debian 13: services, Moonraker, Mainsail, Nginx, backups, log rotation, and optional LAN firewall.
- Read-only audit and status commands.
- Documentation for installation, operations, recovery, migration, and hardware safety.

No desktop environment, OctoPrint, cloud tunnel, password, key, or live backup is included.

## Quick start

Clone the repository on the Debian host and inspect it first:

```bash
git clone https://github.com/KarlAvec1K/Anet_ET4.git
cd Anet_ET4
bash install.sh --audit
bash install.sh --status
```

The installation command requires a real user, trusted LAN subnet, and persistent USB path. It does not move or heat the printer:

```bash
sudo bash install.sh --install \
  --user anet-et4 \
  --trusted-lan-cidr 192.168.18.0/24 \
  --serial /dev/serial/by-id/usb-EXAMPLE \
  --apply
```

Review the configuration diff before using `--apply`. Add `--enable-firewall` only after confirming the trusted subnet and an available local console.

## Documentation

- [Debian 13 installation](docs/installation-debian-13-mini-pc.md)
- [Daily operations](docs/operations.md)
- [Recovery](docs/recovery.md)
- [Hardware safety](docs/hardware-safety.md)
- [Migration from Raspberry Pi](docs/migration-from-raspberry-pi.md)
- [Validation checklist](docs/validation-checklist.md)

## Printer Configuration

`Anet_ET4_Config_files/` contains the printer-specific baseline. The configured MCU connection is under `/dev/serial/by-id/`; do not replace it with `/dev/ttyUSB0`.

The default limits, thermistors, pins, endstops, heater settings, and motion values are hardware-specific. Do not copy them to a different ET4 revision without comparing the board and wiring first.

