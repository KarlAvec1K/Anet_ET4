# Hello world!

Works as is, but knowing myself, it is still a work in progress as I'm always trying to optimize my printer!
I'm still working on making the original Anet ET4 display work with klipper but for now Klipperscreen on an old android phone works like a charm! :)
# What's New?
#### 1. Forked Macros from Jschuh
Incorporated Jschuh's macros into the project and created a new install.sh script. This script automates the transfer of configuration files (.cfg) to /home/pi/printer_data/config, and also sets up a klipper-macros folder with Jschuh's macro configurations.

#### 2. Modified printer.cfg
Adjusted the printer.cfg file to support seamless installation of the macros.

#### 3. Variable Adjustments
Updated key variables such as endstop positions, and minimum/maximum limits to enhance compatibility and performance.

#### 4. Install Script as an Update Manager
The new install.sh script not only installs the necessary files but also functions as an update manager, ensuring you always have the latest version of the configuration and macros.

### Big thank you to Jschuh for all the macros.
- Source : https://github.com/jschuh/klipper-macros

# Installation

#### Simply run the following command in your raspberry pi terminal:

```bash
bash <(curl -sL https://raw.githubusercontent.com/KarlAvec1K/Anet_ET4/dev/install.sh)
```

## Slicer Configuration

### PrusaSlicer / SuperSlicer

PrusaSlicer and its variants are fairly easy to configure. Just open **Printer
Settings → Custom G-code** for your Klipper printer and paste the below text
into the relevant sections.

#### Start G-code

```
M190 S0 ; Remove this if autoemit_temperature_commands is off in Prusa Slicer 2.6 and later
M109 S0 ; Remove this if autoemit_temperature_commands is off in Prusa Slicer 2.6 and later
_PRINT_START_PHASE_INIT EXTRUDER={first_layer_temperature[initial_tool]} BED=[first_layer_bed_temperature] MESH_MIN={first_layer_print_min[0]},{first_layer_print_min[1]} MESH_MAX={first_layer_print_max[0]},{first_layer_print_max[1]} LAYERS={total_layer_count} NOZZLE_SIZE={nozzle_diameter[0]}
; Insert custom gcode here.
_PRINT_START_PHASE_PREHEAT
; Insert custom gcode here.
_PRINT_START_PHASE_PROBING
; Insert custom gcode here.
_PRINT_START_PHASE_EXTRUDER
; Insert custom gcode here.
_PRINT_START_PHASE_PURGE

; This is the place to put slicer purge lines if you haven't set a non-zero
; variable_start_purge_length to have START_PRINT automatically calculate and 
; perform the purge (e.g. if using a Mosaic Palette, which requires the slicer
; to generate the purge).
```

#### Additional SuperSlicer Start G-code

If you're using SuperSlicer you can add the following immediately before the
`PRINT_START` line from above. This will perform some added bounds checking and
will allow you to use the random print relocation feature without requiring
`exclude_object` entries in the print file.

```
PRINT_START_SET MODEL_MIN={bounding_box[0]},{bounding_box[1]} MODEL_MAX={bounding_box[3]},{bounding_box[4]}
```

#### End G-code

```
PRINT_END
```

#### Before layer change G-code

```
;BEFORE_LAYER_CHANGE
;[layer_z]
BEFORE_LAYER_CHANGE HEIGHT=[layer_z] LAYER=[layer_num]
```

#### After layer change G-code

```
;AFTER_LAYER_CHANGE
;[layer_z]
AFTER_LAYER_CHANGE
```

### Ultimaker Cura

Cura is a bit more difficult to configure, and it comes with the following known
issues:

- Cura doesn't have proper placeholders for before and after layer changes, so
  the before triggers all fire and are followed immediately by the after
  triggers, all of which happens inside the layer change. This probably doesn't
  matter, but it does mean that you can't use the before and after triggers to
  avoid running code in the layer change.
- Cura doesn't provide the Z-height of the current layer, so it's inferred from
  the current nozzle position, which will include the Z-hop if the nozzle is
  currently raised. This means height based gcode triggers may fire earlier than
  expected.
- Cura's **Insert at layer change** fires the `After` trigger and then the
  `Before` trigger (i.e before or after the *layer*, versus before or after the
  *layer change*). These macros and PrusaSlicer do the opposite, which is
  something to keep in mind if you're used to how Cura does it. Note that these
  macros do use an  **Insert at layer change** script to force `LAYER` comment
  generation, but that doesn't affect the trigger ordering.
- Cura does not provide the first layer bounding rectangle, only the model
  bounding volume. This means the XY bounding box used to speed up mesh probing
  may be larger than it needs to be, resulting in bed probing that's not as fast
  as it could be. 

Accepting the caveats, the macros work quite well with Cura if you follow the
configuration steps listed below.

#### Start G-code

```
M190 S0
M109 S0
_PRINT_START_PHASE_INIT EXTRUDER={material_print_temperature_layer_0} BED={material_bed_temperature_layer_0} NOZZLE_SIZE={machine_nozzle_size}
; Insert custom gcode here.
_PRINT_START_PHASE_PREHEAT
; Insert custom gcode here.
_PRINT_START_PHASE_PROBING
; Insert custom gcode here.
_PRINT_START_PHASE_EXTRUDER
; Insert custom gcode here.
_PRINT_START_PHASE_PURGE

; This is the place to put slicer purge lines if you haven't set a non-zero
; variable_start_purge_length to have START_PRINT automatically calculate and 
; perform the purge (e.g. if using a Mosaic Palette, which requires the slicer
; to generate the purge).
```

#### End G-code

```
PRINT_END
```

#### Post Processing Plugin

Use the menu item for **Extensions → Post Processing → Modify G-Code** to
open the **Post Processing Plugin** and add the following four scripts. *The
scripts must be run in the order listed below and be sure to copy the strings
exactly, with no leading or trailing spaces.*

##### Search and Replace

- Search: `(\n;(MIN|MAX)X:([^\n]+)\n;\2Y:([^\n]+))`
- Replace: `\1\nPRINT_START_SET MESH_\2=\3,\4`
- Use Regular Expressions: ☑️

##### Search and Replace

- Search: `(\n;LAYER_COUNT:([^\n]+))`
- Replace: `\1\nINIT_LAYER_GCODE LAYERS=\2\nPRINT_START_SET LAYERS=\2`
- Use Regular Expressions: ☑️

##### Insert at layer change

- When to insert: `Before`
- G-code to insert: `;BEFORE_LAYER_CHANGE`

##### Search and Replace

- Search: `(\n;LAYER:([^\n]+))`
- Replace: `\1\nBEFORE_LAYER_CHANGE LAYER=\2\nAFTER_LAYER_CHANGE`
- Use Regular Expressions: ☑️


