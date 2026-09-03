# Hardware Safety

This repository does not prove that a particular printer is mechanically or electrically safe.

- Never heat the nozzle or bed until the thermistors, heater cartridges, wiring, and mounting are physically confirmed.
- Never home, move, extrude, or test endstops without a person beside the printer and clear travel space.
- Never flash the ET4 MCU from this repository without an explicit board and firmware confirmation.
- Confirm the board is Anet ET4-MB v1.1 before trusting the committed pin mapping.
- Confirm the CH340 USB device is the printer before selecting its persistent by-id link.
- The stock thermistor and conservative motion configuration are documented baseline values, not a substitute for hardware inspection.
- The x86 mini-PC intentionally omits `temperature_host`; it may not expose the Raspberry Pi thermal sysfs path used by that Klipper sensor.

Before first print, complete every manual item in [the validation checklist](validation-checklist.md).
