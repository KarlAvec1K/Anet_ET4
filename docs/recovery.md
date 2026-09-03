# Recovery

## Restore a scheduled backup

Backups are stored in `/var/backups/anet-et4/` with SHA-256 checksums.

```bash
sudo systemctl stop moonraker klipper nginx
sudo find /var/backups/anet-et4 -mindepth 1 -maxdepth 1 -type d -printf '%f\\n' | sort
sudo tar -xzf /var/backups/anet-et4/TIMESTAMP/printer-data-config.tar.gz -C /home/anet-et4/printer_data
sudo tar -xzf /var/backups/anet-et4/TIMESTAMP/system-hardening.tar.gz -C /
sudo chown -R anet-et4:anet-et4 /home/anet-et4/printer_data
sudo systemctl daemon-reload
sudo nginx -t
sudo sshd -t
sudo nft -c -f /etc/nftables.conf
sudo systemctl enable --now nginx klipper moonraker anet-et4-backup.timer
```

## Firewall emergency recovery

From the physical console only:

```bash
sudo nft flush ruleset
sudo systemctl disable --now nftables.service
```

Do not use these commands remotely unless an existing SSH connection is known to remain open.
