extends "res://scripts/world/perf_world_probe.gd"
# Shoot from inside the vista-visible northwest rim region.
func world_script_perf() -> Script: return preload("res://scripts/world/woodland_world204.gd")
func out_path_perf() -> String: return "res://docs/perf204-vistaregion-report.json"
func prefix_perf() -> String: return "perf204vista"
func spots_perf() -> void:
 sample._teleport15(Vector2(-55.,-60.7));await hour(12.);await settle(120)
 var vista: Node3D=null
 var stack: Array=[sample]
 while not stack.is_empty():
  var node: Node=stack.pop_back()
  for child in node.get_children(): stack.push_back(child)
  if node.name=="WorldAnchoredDistantCoast141": vista=node
 if vista!=null:
  var ink: ShaderMaterial=vista.panorama141.material_override
  print("VISTAREGION visible=",vista.panorama141.is_visible_in_tree()," opacity=",vista.opacity141," tintAlpha=",Color(ink.get_shader_parameter("tint")).a)
 await measure("vista_region_day")
 await shot_perf("vista_region_day")
