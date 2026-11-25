extends "res://scripts/room/room_shell374.gd"
var source375:=PackedVector3Array()
var uv375:=PackedVector2Array()
var index375:=PackedInt32Array()
var proxy_key375: Array=[]
var layer375:=true
var body_source375:=PackedVector3Array()
var body_uv375:=PackedVector2Array()
var original_body375: Mesh
var original_head375: Mesh
var proxy_depth375:=0.
var pillow_depth375:=0.
func build_furniture() -> void:
 super.build_furniture()
 pose_material369.shader=preload("res://scripts/room/sleep_pose375.gdshader")
 original_head375=head369.mesh;original_body375=body369.mesh
 for y in 25:
  for x in 21:
   var uv:=Vector2(float(x)/20.,float(y)/24.*.52);uv375.append(uv);source375.append(SLEEP369.point369(uv))
   var body_uv:=Vector2(float(x)/20.,.52+float(y)/24.*.48);body_uv375.append(body_uv);body_source375.append(SLEEP369.point369(body_uv))
 for y in 24:
  for x in 20:
   var i:=y*21+x
   for offset in [0,21,1,1,21,22]:index375.append(i+offset)
func _process(delta: float) -> void:
 super._process(delta)
 if not is_instance_valid(head369):return
 if not layer375:
  head369.mesh=original_head375;body369.mesh=original_body375;proxy_key375=[];return
 if not occupied368 or old_pose369:return
 var key: Array=[world.camera.global_transform,craft364.global_transform,pillow364.global_transform,right_pillow368.global_transform]
 if key==proxy_key375:return
 proxy_key375=key
 var eye: Vector3=world.camera.global_position
 var forward: Vector3=-world.camera.global_basis.z.normalized()
 pillow_depth375=1000.
 for pillow in [pillow364,right_pillow368]:
  for node in pillow.get_children():
   if not node is MeshInstance3D:continue
   var bounds: AABB=node.mesh.get_aabb()
   for i in 8:
    var p: Vector3=node.to_global(bounds.get_endpoint(i))
    pillow_depth375=minf(pillow_depth375,(p-eye).dot(forward))
 proxy_depth375=maxf(.2,pillow_depth375-.035)
 head369.mesh=project375(source375,uv375,eye,forward)
 body369.mesh=project375(body_source375,body_uv375,eye,forward)
func project375(points: PackedVector3Array,uvs: PackedVector2Array,eye: Vector3,forward: Vector3) -> ArrayMesh:
 var positions:=PackedVector3Array();var normals:=PackedVector3Array()
 var inverse: Transform3D=craft364.global_transform.affine_inverse()
 for source in points:
  var p: Vector3=craft364.to_global(source)
  var ray:=p-eye;var depth:=ray.dot(forward)
  positions.append(inverse*(eye+ray*(minf(depth,proxy_depth375)/maxf(.01,depth))));normals.append(Vector3.UP)
 var arrays:=[];arrays.resize(Mesh.ARRAY_MAX);arrays[Mesh.ARRAY_VERTEX]=positions;arrays[Mesh.ARRAY_NORMAL]=normals;arrays[Mesh.ARRAY_TEX_UV]=uvs;arrays[Mesh.ARRAY_INDEX]=index375
 var mesh:=ArrayMesh.new();mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES,arrays);return mesh
