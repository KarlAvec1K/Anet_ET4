# Validation Checklist

## Automated and read-only

- [ ] `bash install.sh --audit` completes.
- [ ] The selected USB link exists under `/dev/serial/by-id/`.
- [ ] `systemctl is-active klipper moonraker nginx` returns `active`.
- [ ] `systemctl is-enabled klipper moonraker nginx anet-et4-backup.timer` returns `enabled`.
- [ ] Mainsail returns HTTP 200 from the trusted LAN.
- [ ] Moonraker reports Klipper state `ready`.
- [ ] Extruder and bed temperatures are plausible and their targets are zero.
- [ ] A backup archive checksum verifies.
- [ ] After a controlled host reboot, services and the USB by-id link return.

## Manual, person present

- [ ] USB unplug/replug recovery is observed.
- [ ] Thermistors, heaters, nozzle, bed, fans, endstops, motors, and wiring are inspected.
- [ ] Any first motion, homing, extrusion, or heating test is explicitly authorized and supervised.
- [ ] Conservative first-print settings are selected; no aggressive speed, acceleration, or temperature profile is imported.
