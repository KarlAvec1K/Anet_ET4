; Cura 5.14 machine start G-code for the ET4 phased klipper-macros workflow.
; The first-layer bounds drive the existing DRAW_PURGE_LINE macro.
; Klipper's ADAPTIVE=1 mesh uses Moonraker's EXCLUDE_OBJECT_DEFINE polygons.
M190 S0
M109 S0
M117
_PRINT_START_PHASE_INIT EXTRUDER={material_print_temperature_layer_0} BED={material_bed_temperature_layer_0} NOZZLE_SIZE={machine_nozzle_size}
PRINT_START_SET MESH_MIN={initial_layer_bb_min_x},{initial_layer_bb_min_y} MESH_MAX={initial_layer_bb_max_x},{initial_layer_bb_max_y}
_PRINT_START_PHASE_PREHEAT
_PRINT_START_PHASE_PROBING
_PRINT_START_PHASE_EXTRUDER
_PRINT_START_PHASE_PURGE
