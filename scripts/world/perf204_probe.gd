extends "res://scripts/world/perf_world_probe.gd"
func world_script_perf() -> Script: return preload("res://scripts/world/woodland_world204.gd")
func out_path_perf() -> String: return "res://docs/perf204-report.json"
func prefix_perf() -> String: return "perf204"
func spots_perf() -> void:
 sample._teleport15(Vector2(-4.7,-2.6));await hour(12.)
 await measure("yard_day");await shot_perf("yard_day")
 sample.fade_enabled=false;await settle(60);await measure("yard_day_fadeoff")
 sample.fade_enabled=true;await settle(60)
 sample._teleport15(Vector2(-48.,24.));await hour(12.)
 await measure("forest_center_day");await shot_perf("forest_center_day")
 sample.fade_enabled=false;await settle(60);await measure("forest_center_day_fadeoff")
 sample.fade_enabled=true;await settle(60)
 await hour(22.);await measure("forest_center_night");await shot_perf("forest_center_night")
 var lighting: Object=sample.get("lighting191")
 if lighting!=null and is_instance_valid(lighting):
  lighting.enabled=false;await settle(150);await measure("forest_center_night_lampsoff")
  lighting.enabled=true;await settle(150)
 await hour(12.);await settle(60)
 root.size=Vector2i(800,500);await settle(60);await measure("forest_center_day_halfres")
 root.size=Vector2i(1600,1000);await settle(60)
 sample._teleport15(Vector2(-52.,28.));await settle(60);await measure("forest_west_day")
 sample._teleport15(Vector2(-58.,16.8));await settle(60);await measure("cottage_day")
 sample._teleport15(Vector2(-33.,31.));await settle(60);await measure("stairs_day")
 var forest: Object=sample.get("forest188")
 if forest!=null and is_instance_valid(forest):
  forest.visible=false;await settle(90);await measure("forest_center_day_noforest")
  forest.visible=true;await settle(90)
 var hidden: Array=[]
 var trees: Array=sample.get("trees")
 for tree in trees:
  var visual: Node=tree.get("visual") if tree != null else null
  if visual!=null and visual is VisualInstance3D and visual.visible:
   visual.visible=false;hidden.append(visual)
 if forest!=null and is_instance_valid(forest): forest.visible=false
 await settle(90);await measure("forest_center_day_notrees")
 for visual in hidden: visual.visible=true
 if forest!=null and is_instance_valid(forest): forest.visible=true
 await settle(60)
