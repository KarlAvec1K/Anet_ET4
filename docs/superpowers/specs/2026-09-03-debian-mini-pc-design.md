# Anet ET4: Debian 13 Mini-PC Reference Deployment

## Purpose

Convert this repository from a Raspberry Pi-oriented configuration synchronizer
into the documented reference deployment for a headless Debian 13 mini-PC that
controls a stock Anet ET4 through USB with Klipper, Moonraker, and Mainsail.

The repository must remain useful for the printer configuration itself while
making the host setup repeatable, inspectable, and safe to maintain remotely.

## Scope and Boundaries

Included:

- Preserve and validate the existing Anet ET4 Klipper configuration tree.
- Replace Raspberry Pi-specific assumptions in the installer and documentation.
- Provide an idempotent Debian 13 installer for Git, Python virtual
  environments, Klipper, Moonraker, Mainsail, Nginx, systemd units, backups,
  log rotation, and diagnostics.
- Provide templates for Moonraker, Nginx, systemd hardening, nftables, Polkit,
  scheduled backups, and restoration instructions.
- Define a safe audit and validation sequence that never heats, homes, or moves
  the printer automatically.

Excluded:

- Firmware flashing or rebuilding the MCU firmware.
- Automatic machine motion, homing, extrusion, or heating tests.
- Desktop environments, OctoPrint, reverse proxies exposed to the Internet,
  cloud tunnels, or embedded credentials.
- Versioning live backup archives, SSH private keys, LAN addresses, or local
  secrets.

## Deployment Model

The host runs Debian 13 without a desktop environment.  The service account is
configurable and defaults to `anet-et4`.  Klipper and Moonraker each run in a
dedicated Python virtual environment under that account's home directory.

Runtime paths:

| Component | Path |
| --- | --- |
| Klipper source | `/home/<user>/klipper` |
| Klipper virtual environment | `/home/<user>/klippy-env` |
| Moonraker source | `/home/<user>/moonraker` |
| Moonraker virtual environment | `/home/<user>/moonraker-env` |
| Runtime data | `/home/<user>/printer_data` |
| Configuration | `/home/<user>/printer_data/config` |
| Logs | `/home/<user>/printer_data/logs` |
| UNIX socket | `/home/<user>/printer_data/comms/klippy.sock` |

Klipper must use the persistent USB path under `/dev/serial/by-id/`, never a
volatile `/dev/ttyUSB*` path.  The installer discovers the device but requires
the operator to explicitly select a path if more than one serial USB device is
present.

Mainsail is served by Nginx on TCP 80. Moonraker binds only to loopback on TCP
7125 and is proxied by Nginx. Access is limited to a configurable trusted IPv4
LAN subnet. Nftables limits inbound SSH and HTTP to that subnet; no public
Internet exposure is configured.

## Installer Design

`install.sh` becomes a Bash 5 installation and maintenance entry point with
explicit modes:

- `--audit`: read-only inventory of OS, host resources, network, USB, serial,
  services, repository state, and thermal data.
- `--backup`: create a timestamped configuration and host-settings archive.
- `--install`: require root privileges, take a backup, install dependencies,
  generate files from templates, enable services, and perform non-dangerous
  validation.
- `--sync-config`: compare repository and live configuration, show differences,
  back up the live configuration, then copy only after `--apply` is supplied.
- `--status`: report service state, network listeners, serial link, Klipper
  connection, and current passive temperature readings.

Defaults are conservative. The installer will not overwrite an existing local
configuration without a timestamped backup and a visible diff. It will not
flash firmware, set a heater target, send a motion command, modify the primary
network configuration, or disable an existing web service silently.

## Repository Layout

```text
Anet_ET4_Config_files/       Printer-specific Klipper configuration
deploy/debian/               Host templates and installer helpers
deploy/debian/systemd/       Klipper, Moonraker, backup service and timer
deploy/debian/nginx/         Mainsail reverse-proxy template
deploy/debian/ssh/           Optional SSH hardening drop-in
deploy/debian/nftables/      LAN-only firewall template
deploy/debian/logrotate/     Klipper and Moonraker log rotation
deploy/debian/polkit/        Moonraker service-management rule
docs/                        Installation, security, operations and recovery
scripts/                     Audit, validation and configuration-sync helpers
```

Templates use placeholders such as `__ANET_USER__`, `__TRUSTED_LAN_CIDR__`, and
`__SERIAL_BY_ID__`. Generated files are written to `/etc` only by an explicit
root-run installation mode. No live host-specific path is committed.

## Safety and Security Invariants

- The committed printer configuration targets the Anet ET4-MB v1.1 and stock
  sensors only; hardware mappings are documented rather than guessed.
- Heater and motion operations remain operator-initiated after physical checks.
- The serial account is in `dialout`; services use the persistent by-id path.
- Klipper, Moonraker, and Nginx restart automatically with a bounded delay and
  use conservative systemd sandboxing.
- Backup archives use restrictive permissions, checksums, and 30-day retention.
- SSH remains key-capable. Password hardening is documented, but disabling
  password login is an opt-in operation to avoid locking out an operator.
- Mainsail and SSH are LAN-only. Moonraker is not reachable directly from the
  network.

## Validation Plan

1. Run shell syntax checks for every script and template substitution test.
2. Validate rendered Nginx, nftables, SSH, and systemd files without applying
   potentially disruptive service changes in automated tests.
3. On the host, run the read-only audit before and after installation.
4. Confirm enabled services after a controlled reboot.
5. Confirm HTTP 200 from Mainsail and a Moonraker response through Nginx.
6. Confirm Klipper `ready` state, the selected `/dev/serial/by-id/` link, and
   plausible passive extruder and bed temperatures with targets at zero.
7. Require a human to perform the physical USB reconnect, endstop, movement,
   and heating checks before first printing.

## Migration and Compatibility

Existing Raspberry Pi installations are not modified in place. The legacy
Pi-specific installer is replaced because it assumes `/home/pi`, blindly copies
configuration, and does not manage Moonraker, Mainsail, security boundaries, or
backups. A migration document explains how to take a backup, compare live
configuration, and deploy the mini-PC configuration without deleting the old
host.

The existing current configuration is retained as the printer baseline. The
host temperature sensor remains omitted because a generic x86 Debian mini-PC
may not expose the Raspberry Pi thermal sysfs interface expected by Klipper.

## Acceptance Criteria

- No committed text refers to the mini-PC deployment as a Raspberry Pi setup.
- Installation paths, systemd units, Nginx proxy, Moonraker settings, and
  firewall match the documented deployment model.
- Repository secrets scan is clean and Git status remains clean after tests.
- `shellcheck` findings are resolved where tooling is available; Bash syntax
  checks pass unconditionally.
- The remote mini-PC can use the repository without local configuration being
  overwritten automatically.
