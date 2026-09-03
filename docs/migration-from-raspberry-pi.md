# Migration from Raspberry Pi

Do not overwrite or dismantle a working Raspberry Pi before the mini-PC is independently validated.

1. Record the old printer configuration, macros, Moonraker configuration, serial device, and service state.
2. Take a backup on the old host.
3. Install Debian 13 on the mini-PC and run `bash install.sh --audit`.
4. Compare the repository configuration against the mini-PC with `--sync-config`.
5. Validate passive temperatures and Klipper `ready` state on the mini-PC.
6. Test Mainsail from the trusted LAN.
7. Only then make the mini-PC the normal host.

The legacy `/home/pi` installer is replaced by paths under `/home/<user>`. Do not copy Raspberry Pi host temperature configuration to a generic x86 mini-PC.
