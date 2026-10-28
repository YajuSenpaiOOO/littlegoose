extends "res://scripts/world/perf_world_probe.gd"
# Post-revert verification: merge gone (154 surfaces), and does the lookout
# hilltop show the distant vista and stone wall again?
func world_script_perf() -> Script: return preload("res://scripts/world/woodland_world204.gd")
func out_path_perf() -> String: return "res://docs/perf204-revertcheck-report.json"
func prefix_perf() -> String: return "perf204revert"
func spots_perf() -> void:
 var trim: MeshInstance3D=sample.get_node("/root/@Node3D@2/@MeshInstance3D@5/NorthernBufferTrim140")
 print("REVERT_TRIM surfaces=",trim.mesh.get_surface_count())
 sample._teleport15(Vector2(-12.,-5.2));await hour(12.);await settle(100)
 var vista: Node3D=null
 var lookout: Node3D=null
 var stack: Array=[sample]
 while not stack.is_empty():
  var node: Node=stack.pop_back()
  for child in node.get_children(): stack.push_back(child)
  if node.name=="WorldAnchoredDistantCoast141": vista=node
  if node.name=="LookoutLayers53": lookout=node
 if vista!=null:
  var ink: ShaderMaterial=vista.panorama141.material_override
  print("REVERT_VISTA visible=",vista.panorama141.is_visible_in_tree()," opacity=",vista.opacity141," tint=",ink.get_shader_parameter("tint")," camfar=",sample.camera.far," dist=",sample.camera.global_position.distance_to(vista.panorama141.global_position))
 else: print("REVERT_VISTA node missing")
 if lookout!=null:
  for child in lookout.backdrop.get_children():
   print("REVERT_LOOKOUT ",child.name," visible=",child.is_visible_in_tree())
 else: print("REVERT_LOOKOUT node missing")
 var walls := []
 stack=[sample]
 while not stack.is_empty():
  var node: Node=stack.pop_back()
  for child in node.get_children(): stack.push_back(child)
  if "wall" in node.name.to_lower() or "parapet" in node.name.to_lower() or "石头" in node.name:
   walls.append({"name":node.name,"visible":node.is_visible_in_tree(),"at":str(node.global_position) if node is Node3D else "-"})
 for entry in walls: print("REVERT_WALL ",JSON.stringify(entry))
 print("REVERT_WALLCOUNT ",walls.size())
 await shot_perf("lookout_after_revert")
 sample._teleport15(Vector2(-4.7,-2.6));await settle(60);await shot_perf("yard_after_revert")
