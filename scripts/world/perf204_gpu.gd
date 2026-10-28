extends "res://scripts/world/perf_world_probe.gd"
# Second-pass attribution for 204: full-screen focus/grade quad, forest mood
# per-pixel code, and the forest lamp pipeline, measured in yard and forest.
func world_script_perf() -> Script: return preload("res://scripts/world/woodland_world204.gd")
func out_path_perf() -> String: return "res://docs/perf204-gpu-report.json"
func prefix_perf() -> String: return "perf204gpu"
func spots_perf() -> void:
 sample._teleport15(Vector2(-4.7,-2.6));await hour(12.)
 await measure("yard_day")
 var focus: MeshInstance3D=sample.atmosphere41.focus_card
 focus.visible=false;await settle(60);await measure("yard_day_focuscard_hidden")
 focus.visible=true;await settle(60)
 var mood: Object=sample.get("forest_mood188")
 mood.enabled=false;await settle(150);await measure("yard_day_mood_off")
 mood.enabled=true;await settle(150)
 focus.visible=false;mood.enabled=false;await settle(150);await measure("yard_day_both_off")
 focus.visible=true;mood.enabled=true;await settle(150)
 sample._teleport15(Vector2(-48.,24.));await hour(12.);await settle(60)
 await measure("forest_day")
 focus.visible=false;await settle(60);await measure("forest_day_focuscard_hidden")
 focus.visible=true;await settle(60)
 mood.enabled=false;await settle(150);await measure("forest_day_mood_off")
 mood.enabled=true;await settle(150)
 focus.visible=false;mood.enabled=false;await settle(150);await measure("forest_day_both_off")
 focus.visible=true;mood.enabled=true;await settle(60)
