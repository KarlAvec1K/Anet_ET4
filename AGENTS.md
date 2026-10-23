# Anet ET4 Repository Instructions

## Scope

This repository describes a stock Anet ET4-MB v1.1 running Klipper, Moonraker,
and Mainsail on Debian. Pins, thermistors, motion limits, and wiring are
hardware-specific; compare against the live machine before changing them.

## Validation

Use the narrow checks relevant to the change:

```bash
bash -n install.sh
bash tests/test-templates.sh
bash tests/run.sh
git diff --check
```

`bash install.sh --audit` and `bash install.sh --status` are read-only checks.
An apply or service restart requires an existing backup and explicit approval.

## Printer operations

- Read current Moonraker/Klipper state and heater targets before printer work.
- Keep homing, motion, heat, extrusion, and printing supervised and explicitly
  authorized. Do not flash the controller as part of configuration work.
- The live adaptive mesh uses the existing `_km_mesh_if_needed` macro patched
  to call `_KM_BED_MESH_CALIBRATE_BASE ADAPTIVE=1`. Do not include KAMP's
  `Adaptive_Meshing.cfg`; it conflicts with this installation's mesh wrapper.
- Keep `DRAW_PURGE_LINE` as the sole purge path. `SMART_PARK` is not enabled
  because `klipper-macros` already parks during nozzle-temperature waits.
- Never publish `moonraker.conf`, personal `variables.cfg`, backups, or
  credentials.

## Git changes

Inspect branch, remote, status, and diffs first. Stage only task files; preserve
unrelated user changes and untracked data.
