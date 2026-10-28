extends "res://scripts/world/perf_world_probe.gd"
# The hitch hides in the remaining processors: list them all, then enable
# them in two halves to corner it.
func world_script_perf() -> Script: return preload("res://scripts/world/woodland_world204.gd")
func out_path_perf() -> String: return "res://docs/perf204-remain-report.json"
func prefix_perf() -> String: return "perf204remain"
func enable(nodes: Array) -> void:
 for node in nodes:
  if node!=null:
   node.set_process(true);node.set_physics_process(true)
func spots_perf() -> void:
 sample._teleport15(Vector2(-48.,24.));await hour(12.)
 var covered: Array=[sample,sample.hero]
 var silhouettes: Array=[];var enemies: Array=[]
 var stack: Array=[sample]
 while not stack.is_empty():
  var node: Node=stack.pop_back()
  for child in node.get_children(): stack.push_back(child)
  if node.name=="GroundedActorSilhouette": silhouettes.append(node);covered.append(node)
  if node is CharacterBody3D and node!=sample.hero and node!=sample: enemies.append(node);covered.append(node)
 for key in ["lighting191","forest_mood188","relations199","frames66","time55"]:
  var node: Node=sample.get(key)
  if node!=null: covered.append(node)
 var remaining: Array=[]
 stack=[sample]
 while not stack.is_empty():
  var node: Node=stack.pop_back()
  for child in node.get_children(): stack.push_back(child)
  if (node.is_processing() or node.is_physics_processing()) and not covered.has(node):
   remaining.append(node)
   var script: Script=node.get_script()
   print("REMAIN ",node.name," script=",script.resource_path if script!=null else "-")
 print("REMAIN_COUNT ",remaining.size())
 sample.propagate_call("set_process",[false])
 sample.propagate_call("set_physics_process",[false])
 for node in [sample,sample.hero]: enable([node])
 enable(silhouettes);enable(enemies)
 for key in ["lighting191","forest_mood188","relations199","frames66","time55"]:
  var node: Node=sample.get(key)
  if node!=null: enable([node])
 await settle(90)
 await measure("known_on_rest_off",90,1.6)
 var half := remaining.slice(0,remaining.size()/2)
 enable(half);await settle(90);await measure("plus_first_half",90,1.6)
 enable(remaining.slice(remaining.size()/2));await settle(90);await measure("plus_second_half",90,1.6)
