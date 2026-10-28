extends "res://scripts/world/perf_world_probe.gd"
# Inspect the northern trim meshes: surface counts and AABB extents.
func world_script_perf() -> Script: return preload("res://scripts/world/woodland_world204.gd")
func out_path_perf() -> String: return "res://docs/perf204-trims-report.json"
func prefix_perf() -> String: return "perf204trims"
func spots_perf() -> void:
 for path in ["/root/@Node3D@2/@MeshInstance3D@5","/root/@Node3D@2/@MeshInstance3D@5/NorthernBufferTrim140","/root/@Node3D@2/RockFacesAndGrassCaps91/FacetedBedrock91","/root/@Node3D@2/RockFacesAndGrassCaps91/FacetedBedrock91/NorthernRockTrim140"]:
  var node: Node=sample.get_node(path)
  if node is MeshInstance3D:
   var mesh: Mesh=node.mesh
   var info := {"path":path,"surfaces":mesh.get_surface_count() if mesh!=null else 0,"aabb":str(node.get_aabb()),"global_aabb":str(node.global_transform*node.get_aabb())}
   var tris := 0
   var per_surface: Array=[]
   if mesh!=null:
    for surface in mesh.get_surface_count():
     var arrays: Array=mesh.surface_get_arrays(surface)
     var count: int=arrays[Mesh.ARRAY_VERTEX].size()/3 if not arrays.is_empty() else 0
     tris+=count;per_surface.append(count)
   info.tris=tris;info.sample_surface_tris=per_surface.slice(0,8)
   print("TRIM ",JSON.stringify(info))
 report.trims="see log"
