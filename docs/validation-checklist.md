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

## Observed supervised smoke test — 2026-10-23

- [x] Native adaptive mesh path completed using a synthetic 40 x 40 mm object; Klipper adapted the configured area to 60 x 60 mm and probed a 3 x 3 grid. The mesh was temporary and cleared afterward.
- [x] Existing `DRAW_PURGE_LINE` macro ran for a reduced 5 mm purge plus its configured 12 mm prime at a 210 C nozzle target. The bed heater stayed off. Klipper commanded 17.05194 mm of extrusion.
- [x] Klipper remained `ready`; print state remained `standby`; heater targets were set back to zero; temporary mesh and object data were cleared.
- [x] Karl visually confirmed filament flow and formation of the purge line.
- [ ] Assess line adhesion and first-layer quality on a supervised print.
- [ ] Test the slicer-generated object bounds and run a supervised complete first print after all physical inspection items above are complete.
