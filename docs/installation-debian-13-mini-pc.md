# Debian 13 Mini-PC Installation

## Preconditions

- Debian 13 without a desktop environment.
- A local console available if firewall rules must be recovered.
- An Anet ET4-MB v1.1 connected by USB and visible under `/dev/serial/by-id/`.
- A trusted IPv4 LAN CIDR, for example `192.168.18.0/24`.

Start with a read-only audit:

```bash
bash install.sh --audit
ls -l /dev/serial/by-id/
```

Choose the CH340-style persistent link for `--serial`. Never use a volatile `/dev/ttyUSB0` value.

## Install

The installer installs Git, Python virtual environments, Klipper, Moonraker, Mainsail, Nginx, diagnostics, logrotate, and backup scheduling. It creates services under `/home/<user>/` and adds the service account to `dialout`.

```bash
sudo bash install.sh --install \
  --user anet-et4 \
  --trusted-lan-cidr 192.168.18.0/24 \
  --serial /dev/serial/by-id/usb-EXAMPLE \
  --apply
```

For a first installation, omit `--apply` to inspect the config comparison, then rerun with it. Existing configuration is backed up before copying.

The firewall template is installed but intentionally not enabled by default:

```bash
sudo bash install.sh --install ... --apply --enable-firewall
```

This permits SSH and Mainsail only from the declared IPv4 LAN. Do not enable it without a local recovery console.

## Result

Mainsail is served at `http://<mini-pc-ip>/`. Moonraker listens only on `127.0.0.1:7125` and is proxied by Nginx.
