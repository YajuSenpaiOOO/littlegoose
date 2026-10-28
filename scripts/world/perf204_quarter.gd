extends "res://scripts/world/perf_world_probe.gd"
# Quarter the remaining processors to isolate the ~1 s hitch carrier.
func world_script_perf() -> Script: return preload("res://scripts/world/woodland_world204.gd")
func out_path_perf() -> String: return "res://docs/perf204-quarter-report.json"
func prefix_perf() -> String: return "perf204quarter"
func enable(nodes: Array) -> void:
 for node in nodes:
  if node!=null:
   node.set_process(true);node.set_physics_process(true)
func spots_perf() -> void:
 sample._teleport15(Vector2(-48.,24.));await hour(12.)
 var covered: Array=[sample,sample.hero]
 var stack: Array=[sample]
 while not stack.is_empty():
  var node: Node=stack.pop_back()
  for child in node.get_children(): stack.push_back(child)
  if node.name=="GroundedActorSilhouette" or (node is CharacterBody3D and node!=sample.hero and node!=sample): covered.append(node)
 for key in ["lighting191","forest_mood188","relations199","frames66","time55"]:
  var node: Node=sample.get(key)
  if node!=null: covered.append(node)
 var remaining: Array=[]
 stack=[sample]
 while not stack.is_empty():
  var node: Node=stack.pop_back()
  for child in node.get_children(): stack.push_back(child)
  if (node.is_processing() or node.is_physics_processing()) and not covered.has(node): remaining.append(node)
 for i in remaining.size():
  var script: Script=remaining[i].get_script()
  print("QUARTER_ITEM ",i," ",remaining[i].name," script=",script.resource_path if script!=null else "-")
 sample.propagate_call("set_process",[false])
 sample.propagate_call("set_physics_process",[false])
 enable([sample,sample.hero])
 stack=[sample]
 while not stack.is_empty():
  var node: Node=stack.pop_back()
  for child in node.get_children(): stack.push_back(child)
  if covered.has(node) and node!=sample and node!=sample.hero: enable([node])
 await settle(90)
 await measure("known_only",90,1.6)
 var quarter := remaining.size()/4
 enable(remaining.slice(0,quarter));await settle(90);await measure("plus_q1",90,1.6)
 enable(remaining.slice(quarter,quarter*2));await settle(90);await measure("plus_q2",90,1.6)
 enable(remaining.slice(quarter*2,quarter*3));await settle(90);await measure("plus_q3",90,1.6)
 enable(remaining.slice(quarter*3));await settle(90);await measure("plus_q4",90,1.6)
