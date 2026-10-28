extends "res://scripts/world/perf_world_probe.gd"
# Isolate which per-frame system costs the most: toggle one node's
# processing at a time at the forest center and measure.
func world_script_perf() -> Script: return preload("res://scripts/world/woodland_world204.gd")
func out_path_perf() -> String: return "res://docs/perf204-bisect-report.json"
func prefix_perf() -> String: return "perf204bisect"
func find_by_name(root_node: Node,wanted: String) -> Node:
 if root_node.name==wanted: return root_node
 for child in root_node.get_children():
  var hit: Node=find_by_name(child,wanted)
  if hit!=null: return hit
 return null
func toggle_measure(tag: String,node: Node,physics := false) -> void:
 if node!=null:
  if physics: node.set_physics_process(false)
  else: node.set_process(false)
 await settle(90)
 var entry: Dictionary=await measure(tag,90,1.6)
 if node!=null:
  if physics: node.set_physics_process(true)
  else: node.set_process(true)
 await settle(45)
func spots_perf() -> void:
 sample._teleport15(Vector2(-48.,24.));await hour(12.)
 await measure("baseline",90,1.6)
 var life: Node=find_by_name(sample,"WoodlandLife46")
 print("BISECT life_found=",life!=null," wind_materials=",life.wind_materials.size() if life!=null else -1)
 await toggle_measure("woodland_life_off",life)
 var frames: Node=sample.get("frames66")
 await toggle_measure("frame_overlay_off",frames)
 var relations: Node=sample.get("relations199")
 await toggle_measure("prop_relations_off",relations)
 var lighting: Node=sample.get("lighting191")
 await toggle_measure("forest_lighting_off",lighting)
 var mood: Node=sample.get("forest_mood188")
 await toggle_measure("forest_mood_off",mood)
 var atmosphere: Node=sample.get("atmosphere41")
 await toggle_measure("atmosphere_off",atmosphere)
 await toggle_measure("world_physics_off",sample,true)
 await toggle_measure("world_process_off",sample,false)
