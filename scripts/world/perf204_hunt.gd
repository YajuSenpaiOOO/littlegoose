extends "res://scripts/world/perf_world_probe.gd"
# Enumerate every node that still processes, then hunt the ~1s hitch by
# disabling UI/clock suspects one by one.
func world_script_perf() -> Script: return preload("res://scripts/world/woodland_world204.gd")
func out_path_perf() -> String: return "res://docs/perf204-hunt-report.json"
func prefix_perf() -> String: return "perf204hunt"
func toggle_measure(tag: String,nodes: Array) -> void:
 for node in nodes:
  if node!=null: node.set_process(false)
 await settle(90)
 var entry: Dictionary=await measure(tag,90,1.6)
 for node in nodes:
  if node!=null: node.set_process(true)
 await settle(45)
func spots_perf() -> void:
 sample._teleport15(Vector2(-48.,24.));await hour(12.)
 var processing := []
 var stack: Array=[sample]
 while not stack.is_empty():
  var node: Node=stack.pop_back()
  for child in node.get_children(): stack.push_back(child)
  if node.is_processing() or node.is_physics_processing():
   var script: Script=node.get_script()
   processing.append(node)
   print("HUNT_PROCESSOR ",node.name," script=",script.resource_path if script!=null else "-"," proc=",node.is_processing()," phys=",node.is_physics_processing())
 print("HUNT_COUNT ",processing.size())
 await measure("hunt_baseline",90,1.6)
 var time55: Node=sample.get("time55")
 await toggle_measure("time55_off",[time55])
 var guides: Array=[]
 stack=[sample]
 while not stack.is_empty():
  var node: Node=stack.pop_back()
  for child in node.get_children(): stack.push_back(child)
  if node is CanvasLayer or node is Control:
   if node.is_processing(): guides.append(node)
 print("HUNT_UI_COUNT ",guides.size())
 await toggle_measure("ui_off",guides)
