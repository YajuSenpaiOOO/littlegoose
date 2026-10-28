extends "res://scripts/world/perf_world_probe.gd"
# Group bisection from a fully-frozen tree: re-enable one group at a time
# and watch which group brings the ~1 s / ~60 ms hitch back.
func world_script_perf() -> Script: return preload("res://scripts/world/woodland_world204.gd")
func out_path_perf() -> String: return "res://docs/perf204-groupbisect-report.json"
func prefix_perf() -> String: return "perf204group"
func enable(nodes: Array) -> void:
 for node in nodes:
  if node!=null:
   node.set_process(true);node.set_physics_process(true)
func spots_perf() -> void:
 sample._teleport15(Vector2(-48.,24.));await hour(12.)
 var silhouettes: Array=[];var enemies: Array=[];var art: Array=[]
 var stack: Array=[sample]
 while not stack.is_empty():
  var node: Node=stack.pop_back()
  for child in node.get_children(): stack.push_back(child)
  if node.name=="GroundedActorSilhouette": silhouettes.append(node)
  if node is CharacterBody3D and node!=sample.hero and node!=sample: enemies.append(node)
 var lighting: Node=sample.get("lighting191");var mood: Node=sample.get("forest_mood188")
 var relations: Node=sample.get("relations199");var frames: Node=sample.get("frames66")
 var life: Node=null;var grade: Node=null;var art201: Node=null
 stack=[sample]
 while not stack.is_empty():
  var node: Node=stack.pop_back()
  for child in node.get_children(): stack.push_back(child)
  if node.name=="WoodlandLife46": life=node
  if node.get_script()!=null and str(node.get_script().resource_path).contains("enemy_grade193"): grade=node
  if node.name=="GroundedBases187": art201=node
 art=[lighting,mood,relations,life,grade,art201]
 var time55: Node=sample.get("time55")
 print("GROUPS silhouettes=",silhouettes.size()," enemies=",enemies.size()," art=",art.size())
 sample.propagate_call("set_process",[false])
 sample.propagate_call("set_physics_process",[false])
 await settle(90)
 await measure("all_off",90,1.6)
 enable([sample]);await settle(90);await measure("plus_world_root",90,1.6)
 enable([sample.hero]);await settle(90);await measure("plus_hero",90,1.6)
 enable(silhouettes);await settle(90);await measure("plus_silhouettes",90,1.6)
 enable(enemies);await settle(90);await measure("plus_enemies",90,1.6)
 enable([time55]);await settle(90);await measure("plus_time55",90,1.6)
 enable(art);await settle(90);await measure("plus_art_systems",90,1.6)
 enable([frames]);await settle(90);await measure("plus_overlay",90,1.6)
