extends "res://scripts/world/perf_world_probe.gd"
# Can the 154 terrain surfaces merge losslessly? Check material/format uniformity.
func world_script_perf() -> Script: return preload("res://scripts/world/woodland_world204.gd")
func out_path_perf() -> String: return "res://docs/perf204-trimmaterial-report.json"
func prefix_perf() -> String: return "perf204trimmat"
func spots_perf() -> void:
 for path in ["/root/@Node3D@2/@MeshInstance3D@5","/root/@Node3D@2/@MeshInstance3D@5/NorthernBufferTrim140"]:
  var node: MeshInstance3D=sample.get_node(path)
  var mesh: ArrayMesh=node.mesh
  var materials := {}
  var formats := {}
  var primitive := -1
  var uniform := true
  for surface in mesh.get_surface_count():
   var mat: Material=node.get_surface_override_material(surface)
   if mat==null: mat=mesh.surface_get_material(surface)
   if mat==null: mat=node.material_override
   materials[mat.get_instance_id() if mat!=null else 0]=true
   var fmt: int=mesh.surface_get_format(surface)
   formats[fmt]=true
   var mode: int=mesh.surface_get_primitive_type(surface)
   if primitive==-1: primitive=mode
   elif primitive!=mode: uniform=false
  print("TRIMMAT ",JSON.stringify({"path":path,"surfaces":mesh.get_surface_count(),"distinct_materials":materials.size(),"distinct_formats":formats.size(),"one_primitive_type":uniform}))
 report.note="see log"
