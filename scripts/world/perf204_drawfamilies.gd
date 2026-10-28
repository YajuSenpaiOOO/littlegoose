extends "res://scripts/world/perf_world_probe.gd"
# Attribute the ~650 draw calls to sprite/mesh families by hiding one group
# at a time and watching the draw counter. Output = batching priority list.
func world_script_perf() -> Script: return preload("res://scripts/world/woodland_world204.gd")
func out_path_perf() -> String: return "res://docs/perf204-drawfamilies-report.json"
func prefix_perf() -> String: return "perf204families"
func draws_snapshot() -> int:
 var worst := 0
 for i in 30:
  await process_frame
  worst=maxi(worst,int(Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME)))
 return worst
func group_measure(tag: String,nodes: Array) -> void:
 var saved := []
 for node in nodes:
  if node==null: continue
  saved.append(node.visible);node.visible=false
 await settle(45)
 var hidden: int=await draws_snapshot()
 for i in nodes.size():
  if nodes[i]!=null: nodes[i].visible=saved[i]
 await settle(45)
 report.spots.append({"tag":tag,"draws_hidden":hidden})
 print("FAMILY ",JSON.stringify(report.spots[-1]))
func collect(predicate: Callable) -> Array:
 var result: Array=[]
 var stack: Array=[sample]
 while not stack.is_empty():
  var node: Node=stack.pop_back()
  for child in node.get_children(): stack.push_back(child)
  if predicate.call(node): result.append(node)
 return result
func spots_perf() -> void:
 sample._teleport15(Vector2(-48.,24.));await hour(12.);await settle(120)
 var baseline: int=await draws_snapshot()
 print("FAMILY baseline draws=",baseline)
 report.baseline=baseline
 var tree_visuals := []
 for tree in sample.trees: tree_visuals.append(tree.visual)
 await group_measure("ordinary_trees",tree_visuals)
 var forest: Node=sample.get("forest188")
 await group_measure("forest188_subtree",[forest])
 var shadows := collect(func(node): return node.name=="GroundedActorSilhouette" and node.is_visible_in_tree())
 await group_measure("actor_silhouette_shadows",shadows)
 var grass: Array=[]
 for batch in sample.grass_batches: grass.append(batch.node)
 await group_measure("grass_multimeshes",grass)
 for key in ["garden","park99","rail72","rocks91","bridge59"]:
  var node: Node=sample.get(key)
  await group_measure(key,[node] if node!=null else [])
 var trim: Node=sample.get_node_or_null("/root/@Node3D@2/@MeshInstance3D@5/NorthernBufferTrim140")
 await group_measure("ground_trim",[trim])
 var sprites := collect(func(node): return node is Sprite3D)
 await group_measure("ALL_sprites",sprites)
