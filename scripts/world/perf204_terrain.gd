extends "res://scripts/world/perf_world_probe.gd"
# Terrain/shadow attribution: what is the big mesh, what is the sun doing,
# and how much do terrain shadow casting / sun shadows actually cost.
func world_script_perf() -> Script: return preload("res://scripts/world/woodland_world204.gd")
func out_path_perf() -> String: return "res://docs/perf204-terrain-report.json"
func prefix_perf() -> String: return "perf204terrain"
func mesh_tris(node: MeshInstance3D) -> int:
 var mesh: Mesh=node.mesh
 if mesh==null: return 0
 var total: int=0
 for surface in mesh.get_surface_count():
  var arrays: Array=mesh.surface_get_arrays(surface)
  if arrays.is_empty(): continue
  var verts: PackedVector3Array=arrays[Mesh.ARRAY_VERTEX]
  total+=verts.size()/3
 return total
func big_meshes() -> Array:
 var found: Array=[]
 var stack: Array=[sample]
 while not stack.is_empty():
  var node: Node=stack.pop_back()
  for child in node.get_children(): stack.push_back(child)
  if node is MeshInstance3D:
   var tris := mesh_tris(node)
   if tris>20000:
    var chain := node.get_path()
    found.append({"path":str(chain),"tris":tris,"cast_shadow":node.cast_shadow,"visible":node.is_visible_in_tree()})
 found.sort_custom(func(a,b): return a.tris>b.tris)
 return found
func spots_perf() -> void:
 var sun: DirectionalLight3D=sample.sun
 report.sun={"shadow_enabled":sun.shadow_enabled,"mode":sun.directional_shadow_mode,"max_distance":sun.directional_shadow_max_distance,"blend_splits":sun.directional_shadow_blend_splits,"fade_start":sun.shadowFadeStart() if sun.has_method("shadowFadeStart") else -1}
 print("SUN ",JSON.stringify(report.sun))
 report.big_meshes=big_meshes()
 for entry in report.big_meshes: print("BIGMESH ",JSON.stringify(entry))
 sample._teleport15(Vector2(-48.,24.));await hour(12.)
 await measure("forest_day_baseline");await shot_perf("terrain_before")
 # 1) terrain + big meshes stop casting shadows (they still receive)
 var targets: Array=[]
 for entry in report.big_meshes:
  var node: Node=sample.get_node(entry.path)
  if node is MeshInstance3D and node.cast_shadow!=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF:
   targets.append(node);node.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
 await settle(60);await measure("forest_day_bigmesh_nocast");await shot_perf("terrain_nocast")
 for node in targets: node.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_ON
 await settle(60)
 # 2) sun shadows off entirely (all scene shadow receiving from sun stops)
 var original: bool=sun.shadow_enabled
 sun.shadow_enabled=false;await settle(60);await measure("forest_day_sunshadow_off");await shot_perf("terrain_sunoff")
 sun.shadow_enabled=original;await settle(60)
 # 3) shadow distance 42 -> 18 (closer shadow window, cheaper passes)
 var original_distance: float=sun.directional_shadow_max_distance
 sun.directional_shadow_max_distance=18.;await settle(60);await measure("forest_day_shadowdist18")
 sun.directional_shadow_max_distance=original_distance;await settle(60)
