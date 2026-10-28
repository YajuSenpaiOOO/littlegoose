extends "res://scripts/world/perf_world_probe.gd"
# Follow-up: northern buffer skirt cost in the main pass, and single-split sun.
func world_script_perf() -> Script: return preload("res://scripts/world/woodland_world204.gd")
func out_path_perf() -> String: return "res://docs/perf204-terrain2-report.json"
func prefix_perf() -> String: return "perf204terrain2"
func spots_perf() -> void:
 var buffer: Node=sample.get_node("/root/@Node3D@2/@MeshInstance3D@5/NorthernBufferTrim140")
 var rocks: Node=sample.get_node("/root/@Node3D@2/RockFacesAndGrassCaps91/FacetedBedrock91/NorthernRockTrim140")
 sample._teleport15(Vector2(-4.7,-2.6));await hour(12.)
 await measure("yard_day_baseline")
 buffer.visible=false;rocks.visible=false;await settle(60);await measure("yard_day_no_northtrim")
 buffer.visible=true;rocks.visible=true;await settle(60)
 sample._teleport15(Vector2(-48.,24.));await settle(60)
 await measure("forest_day_baseline")
 await shot_perf("noise_a");await settle(60);await shot_perf("noise_b")
 buffer.visible=false;rocks.visible=false;await settle(60);await measure("forest_day_no_northtrim")
 buffer.visible=true;rocks.visible=true;await settle(60)
 var sun: DirectionalLight3D=sample.sun
 var original_mode: int=sun.directional_shadow_mode
 sun.directional_shadow_mode=DirectionalLight3D.SHADOW_ORTHOGONAL;await settle(60)
 await measure("forest_day_single_split")
 sun.directional_shadow_mode=original_mode;await settle(60)
