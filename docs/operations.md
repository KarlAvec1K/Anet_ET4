# Operations

## Read-only checks

```bash
bash install.sh --status
systemctl status klipper moonraker nginx nftables
journalctl -u klipper -n 100 --no-pager
ls -l /dev/serial/by-id/
```

The Moonraker response includes passive temperatures. Confirm extruder and bed targets are `0` before any physical printer work.

## Service control

These commands restart software only; they do not issue printer motion or heater commands:

```bash
sudo systemctl restart klipper moonraker nginx
sudo systemctl reboot
```

After a USB reconnection, wait for the by-id link to reappear and run `bash install.sh --status`. If Klipper remains disconnected, inspect the USB cable, printer power, `dialout` membership, and `journalctl -u klipper`.

## Updates

```bash
git -C ~/Anet_ET4 pull --ff-only
bash ~/Anet_ET4/install.sh --sync-config
```

Review the diff. Only use `sudo bash ~/Anet_ET4/install.sh --sync-config --apply` when the printer is idle and the backup has completed.
