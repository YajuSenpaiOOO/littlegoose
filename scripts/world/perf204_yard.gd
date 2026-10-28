extends "res://scripts/world/perf_world_probe.gd"
# Third pass: does the forest lamp pipeline cost anything while standing in
# the yard, and how expensive is one whole-tree fade scan in isolation.
func world_script_perf() -> Script: return preload("res://scripts/world/woodland_world204.gd")
func out_path_perf() -> String: return "res://docs/perf204-yard-report.json"
func prefix_perf() -> String: return "perf204yard"
func spots_perf() -> void:
 sample._teleport15(Vector2(-4.7,-2.6));await hour(12.)
 await measure("yard_day")
 var lighting: Object=sample.get("lighting191")
 lighting.enabled=false;await settle(150);await measure("yard_day_lighting_off")
 lighting.enabled=true;await settle(150)
 var whole: Object=sample.get("whole67")
 var scan_cost := []
 for i in 10:
  var t0 := Time.get_ticks_usec();whole._scan();scan_cost.append(Time.get_ticks_usec()-t0)
  await settle(6)
 scan_cost.sort()
 report.scan_ms_yard=scan_cost
 print("SCAN_MS_YARD ",JSON.stringify(scan_cost))
 sample._teleport15(Vector2(-48.,24.));await hour(12.);await settle(60)
 await measure("forest_day")
 var scan_forest := []
 for i in 10:
  var t0 := Time.get_ticks_usec();whole._scan();scan_forest.append(Time.get_ticks_usec()-t0)
  await settle(6)
 scan_forest.sort()
 report.scan_ms_forest=scan_forest
 print("SCAN_MS_FOREST ",JSON.stringify(scan_forest))
