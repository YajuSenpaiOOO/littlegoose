extends "res://scripts/world/perf_world_probe.gd"
# Runtime truth about the distant-scenery systems at the northwest rim.
func world_script_perf() -> Script: return preload("res://scripts/world/woodland_world204.gd")
func out_path_perf() -> String: return "res://docs/perf204-scenery-report.json"
func prefix_perf() -> String: return "perf204scenery"
func spots_perf() -> void:
 sample._teleport15(Vector2(-55.,-60.7));await hour(12.);await settle(150)
 var grove: Vector2=sample.meadow.landmarks.grove
 var p: Vector2=Vector2(sample.hero.position.x,sample.hero.position.z)-grove
 print("SCENERY grove=",grove," hero=",Vector2(sample.hero.position.x,sample.hero.position.z)," p=",p)
 print("SCENERY factors=",(1.-smoothstep(-12.,-2.,p.x)),smoothstep(-55.,-39.,p.y),(1.-smoothstep(8.,22.,p.y)))
 var stack: Array=[sample]
 var found := 0
 while not stack.is_empty():
  var node: Node=stack.pop_back()
  for child in node.get_children(): stack.push_back(child)
  var label: String=node.name.to_lower()
  if "coast" in label or "ridge" in label or "lookout" in label or "vista" in label or "panorama" in label or "distant" in label:
   found+=1
   var script_path: String=node.get_script().resource_path if node.get_script()!=null else "-"
   var extra := ""
   if "opacity141" in node: extra=" opacity141="+str(node.opacity141)+" processing="+str(node.is_processing())
   print("SCENERY_NODE ",node.name," script=",script_path," visible=",node.is_visible_in_tree(),extra)
 print("SCENERY_COUNT ",found)
 await shot_perf("nw_rim_day")
