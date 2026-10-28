extends "res://scripts/world/perf_world_probe.gd"
# One-shot census of triangle counts grouped by the world's top-level owner
# nodes, to attribute the ~2.5M per-frame primitives.
func world_script_perf() -> Script: return preload("res://scripts/world/woodland_world204.gd")
func out_path_perf() -> String: return "res://docs/perf204-meshes.json"
func prefix_perf() -> String: return "perf204mesh"
func tri_count(node: MeshInstance3D) -> int:
 var mesh: Mesh=node.mesh
 if mesh==null: return 0
 var total := 0
 for surface in mesh.get_surface_count():
  var arrays: Array=mesh.surface_get_arrays(surface)
  if arrays.is_empty() or arrays[Mesh.ARRAY_VERTEX].is_empty(): continue
  var mode: int=mesh.surface_get_primitive_type(surface)
  var n: int=arrays[Mesh.ARRAY_VERTEX].size()
  if mode==Mesh.PRIMITIVE_TRIANGLES: total+=n/3
  elif mode==Mesh.PRIMITIVE_TRIANGLE_STRIP: total+= maxi(n-2,0)
  else: total+=n
 return total
func owner_name(node: Node) -> String:
 var walk: Node=node
 while walk!=null and walk!=sample:
  if walk.get_parent()==sample: return walk.name
  walk=walk.get_parent()
 return "(other)"
func spots_perf() -> void:
 var owners := {}
 var stack: Array=[sample]
 while not stack.is_empty():
  var node: Node=stack.pop_back()
  for child in node.get_children(): stack.push_back(child)
  if node is MeshInstance3D and node.is_visible_in_tree():
   var tris := tri_count(node)
   var owner := owner_name(node)
   if not owners.has(owner): owners[owner]={"tris":0,"meshes":0}
   owners[owner].tris+=tris;owners[owner].meshes+=1
 var rows: Array=[]
 for owner in owners: rows.append({"owner":owner,"tris":owners[owner].tris,"meshes":owners[owner].meshes})
 rows.sort_custom(func(a,b): return a.tris>b.tris)
 report.mesh_owners=rows
 for row in rows.slice(0,14): print("MESH_OWNER ",JSON.stringify(row))
