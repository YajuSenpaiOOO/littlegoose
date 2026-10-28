extends "res://scripts/world/perf_world_probe.gd"
func world_script_perf() -> Script: return preload("res://scripts/world/woodland_world169.gd")
func out_path_perf() -> String: return "res://docs/perf169-report.json"
func prefix_perf() -> String: return "perf169"
func spots_perf() -> void:
 var marks: Dictionary=sample.meadow.landmarks
 sample._teleport15(Vector2(-4.7,-2.6));await hour(12.)
 await measure("yard_day");await shot_perf("yard_day")
 sample.fade_enabled=false;await settle(60);await measure("yard_day_fadeoff")
 sample.fade_enabled=true;await settle(60)
 await hour(22.);await measure("yard_night")
 await hour(12.);await settle(60)
 sample._teleport15(Vector2(marks.grove));await settle(60)
 await measure("grove_day");await shot_perf("grove_day")
 root.size=Vector2i(800,500);await settle(60);await measure("grove_day_halfres")
 root.size=Vector2i(1600,1000);await settle(60)
 sample._teleport15(Vector2(marks.station));await settle(60);await measure("station_day")
