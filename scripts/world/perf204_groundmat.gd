extends "res://scripts/world/perf_world_probe.gd"
# What exactly differs across the 154 ground surface materials?
func world_script_perf() -> Script: return preload("res://scripts/world/woodland_world204.gd")
func out_path_perf() -> String: return "res://docs/perf204-groundmat-report.json"
func prefix_perf() -> String: return "perf204gmat"
func spots_perf() -> void:
 var node: MeshInstance3D=sample.get_node("/root/@Node3D@2/@MeshInstance3D@5")
 var mesh: ArrayMesh=node.mesh
 var shaders := {}
 var signatures := {}
 var example_first: Dictionary={}
 var example_last: Dictionary={}
 for surface in mesh.get_surface_count():
  var mat: Material=mesh.surface_get_material(surface)
  var shader: Shader=mat.shader if mat is ShaderMaterial else null
  var path: String=shader.resource_path if shader!=null else str(mat)
  shaders[path]=shaders.get(path,0)+1
  if mat is ShaderMaterial:
   var params := {}
   for uniform in shader.get_shader_uniform_list():
    var value=mat.get_shader_parameter(uniform.name)
    match typeof(value):
     TYPE_VECTOR2,TYPE_VECTOR3,TYPE_COLOR,TYPE_QUATERNION,TYPE_TRANSFORM2D,TYPE_TRANSFORM3D,TYPE_RECT2,TYPE_RECT2I,TYPE_VECTOR2I,TYPE_VECTOR3I,TYPE_VECTOR4,TYPE_VECTOR4I,TYPE_PLANE,TYPE_AABB,TYPE_BASIS,TYPE_PROJECTION: params[uniform.name]=str(value)
     TYPE_FLOAT,TYPE_INT,TYPE_BOOL: params[uniform.name]=value
     TYPE_OBJECT: params[uniform.name]=value.get_instance_id() if value!=null else 0
     _: params[uniform.name]=str(typeof(value))
   var signature: String=str(params)
   if not signatures.has(signature):
    signatures[signature]=[]
    if example_first.is_empty(): example_first=params
    example_last=params
   signatures[signature].append(surface)
 report.ground_materials={"surfaces":mesh.get_surface_count(),"distinct_shaders":shaders,"distinct_param_sets":signatures.size()}
 print("GROUNDMAT ",JSON.stringify(report.ground_materials))
 print("GROUNDMAT_FIRST ",JSON.stringify(example_first))
 print("GROUNDMAT_LAST ",JSON.stringify(example_last))
 var sizes := []
 for signature in signatures: sizes.append(signatures[signature].size())
 sizes.sort()
 print("GROUNDMAT_GROUP_SIZES ",JSON.stringify(sizes.slice(maxi(0,sizes.size()-8),sizes.size())))
