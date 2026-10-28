extends "res://scripts/world/perf_world_probe.gd"
# Before/after night reference shots for the perf fix visual comparison.
func world_script_perf() -> Script: return preload("res://scripts/world/woodland_world204.gd")
func out_path_perf() -> String: return "res://docs/perf204-nightshots.json"
func prefix_perf() -> String: return "perf204night"
func spots_perf() -> void:
 sample._teleport15(Vector2(-58.,16.8));await hour(22.)
 await shot_perf("cottage_night")
 sample._teleport15(Vector2(-33.,31.));await settle(60)
 await shot_perf("stairs_night")
 sample._teleport15(Vector2(-48.,24.));await settle(60)
 await shot_perf("center_night")
