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

## Adaptive mesh and purge

The ET4 uses Klipper's native adaptive mesh inside the existing `_km_mesh_if_needed` macro in `klipper-macros/start_end.cfg`. A separate `rename_existing` override failed Klipper startup on this installation (`Existing command '_KM_MESH_IF_NEEDED' not found`), so do not include that override. The one-line patch is recorded at [`klipper-macros-adaptive-mesh.patch`](../Anet_ET4_Config_files/klipper-configs/overrides/klipper-macros-adaptive-mesh.patch); it calls `_KM_BED_MESH_CALIBRATE_BASE ADAPTIVE=1` when no mesh profile is loaded. This leaves `BED_MESH_CALIBRATE_FAST` available for manual mesh operations. `[exclude_object]` must remain enabled and sliced files need object definitions. See [Klipper's adaptive mesh documentation](https://www.klipper3d.org/Bed_Mesh.html#adaptive-meshes) and the [`klipper-macros` slicer instructions](https://github.com/jschuh/klipper-macros#slicer-configuration).

For Cura 5.14, copy [`examples/cura-5.14-machine-start.gcode`](../examples/cura-5.14-machine-start.gcode) into the printer's Machine Start G-Code. Cura 5.14 provides the `initial_layer_bb_*` variables used for the first-layer bounds; see [Cura's Start/End G-Code reference](https://github.com/Ultimaker/Cura/wiki/Start-End-G%E2%80%90Code). The existing `DRAW_PURGE_LINE` uses those bounds, which avoids adding a second purge macro. The Machine End G-Code is unchanged. `SMART_PARK` remains disabled because `klipper-macros` calls `PARK` when the nozzle needs to wait for its target temperature; adding KAMP's park would require changing that existing path.

### Supervised smoke test — 2026-10-23

Klipper was `ready`, `print_stats` was `standby`, the axes were homed, and both heaters began with target `0`. A synthetic `EXCLUDE_OBJECT_DEFINE` polygon from `(80,80)` to `(120,120)` exercised `_KM_MESH_IF_NEEDED`. Klipper reported adapted mesh bounds `(70,70)` to `(130,130)`, a `3 x 3` probe grid, and `Mesh Bed Leveling Complete`. One probe sample pair at `(130,70)` exceeded tolerance and was retried; the retry completed. The observed probed mesh ranged from `-0.049568 mm` to `0.034182 mm`. The adaptive mesh was not saved.

The existing `DRAW_PURGE_LINE` then ran with `PRINT_MIN=80,80 PRINT_MAX=120,120 LENGTH=5`; the configured `12 mm` prime plus purge commanded `17.05194 mm` of extrusion. The nozzle target was `210 C`; the bed stayed near room temperature with target `0`. Klipper returned `ready`, then the test mesh and object definitions were cleared and heaters were turned off. Karl visually confirmed that filament exited and formed the purge line; line adhesion was not separately assessed.

This smoke test does not validate a Cura-generated file, actual slicer object-bound extraction, the normal `30 mm` purge amount, bed-temperature mesh behavior, or a complete print. Complete the physical inspection items in [the hardware-safety guide](hardware-safety.md) and [the validation checklist](validation-checklist.md) before the first print.
