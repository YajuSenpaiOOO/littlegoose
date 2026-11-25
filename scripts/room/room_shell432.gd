extends "res://scripts/room/room_shell424.gd"

const SLEEP_HEAD = preload("res://assets/house432_interior/sleep-head.png")
const HEAD_ART := Rect2i(43,96,1164,989)
const COMPANION_HEAD = preload("res://assets/house432_interior/sleep-black-goose.png")
const COMPANION_ART := Rect2i(80,85,1106,1045)
var settled_head: MeshInstance3D
var settled_ink: ShaderMaterial
var companion_head: MeshInstance3D
var companion_ink: StandardMaterial3D
var shared_duvet: ArrayMesh
var shared_throw: ArrayMesh

func build_furniture() -> void:
 super.build_furniture()
 # The head and shoulder strip stay in bed space.
 strict370=false
 layer375=false
 settled_ink=ShaderMaterial.new()
 settled_ink.shader=preload("res://scripts/room/sleep_pose369.gdshader")
 var crop:=SLEEP_HEAD.get_image().get_region(HEAD_ART)
 crop.generate_mipmaps()
 settled_ink.set_shader_parameter("pose",ImageTexture.create_from_image(crop))
 settled_head=shape(craft364,settled_head_mesh(),Vector3.ZERO,settled_ink)
 settled_head.name="SettledSleepHead432"
 settled_head.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
 settled_head.hide()
 var companion_crop:=COMPANION_HEAD.get_image().get_region(COMPANION_ART)
 companion_crop.generate_mipmaps()
 companion_ink=StandardMaterial3D.new()
 companion_ink.albedo_texture=ImageTexture.create_from_image(companion_crop)
 companion_ink.shading_mode=BaseMaterial3D.SHADING_MODE_UNSHADED
 companion_ink.transparency=BaseMaterial3D.TRANSPARENCY_ALPHA_SCISSOR
 companion_ink.alpha_scissor_threshold=.5
 companion_ink.cull_mode=BaseMaterial3D.CULL_DISABLED
 companion_ink.texture_filter=BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
 companion_head=shape(craft364,settled_head.mesh,Vector3(1.12,-.025,.025),companion_ink)
 companion_head.name="SleepingBlackGoose432"
 companion_head.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
 companion_head.hide()
 shared_duvet=cover_for_two(new_duvet369)
 shared_throw=cover_for_two(new_throw369)

func set_occupied368(value: bool) -> void:
 super.set_occupied368(value)
 if not is_instance_valid(settled_head):return
 sleep_root369.hide()
 settled_head.visible=value
 if value:
  pillow364.transform=empty_pillow_transform368
  left_body368.mesh=empty_pillow_mesh368
  contact_pillow364.position.z=-.91
  head_contact368.position.z=.174

func _process(delta: float) -> void:
 super._process(delta)
 if is_instance_valid(settled_head) and occupied368:
  var tint: Vector3=pose_material369.get_shader_parameter("room_tint")
  settled_ink.set_shader_parameter("room_tint",tint)
  companion_ink.albedo_color=Color(tint.x,tint.y,tint.z).linear_to_srgb()

func set_companion_sleep(value: bool) -> void:
 companion_head.visible=value
 if occupied368:
  duvet_mesh366.mesh=shared_duvet if value else new_duvet369
  throw_mesh366.mesh=shared_throw if value else new_throw369

func cover_for_two(source: ArrayMesh) -> ArrayMesh:
 var arrays:=source.surface_get_arrays(0)
 var vertices: PackedVector3Array=arrays[Mesh.ARRAY_VERTEX]
 var normals: PackedVector3Array=arrays[Mesh.ARRAY_NORMAL]
 for i in vertices.size():
  var point:=vertices[i]
  var lift:=SLEEP368.body_lift368(-point.x,point.z)
  var dx:=2.*(.56-point.x)/(.29*.29)*lift
  var dz:=-2.*(point.z-.15)/(.75*.75)*lift
  vertices[i].y+=lift
  normals[i]=(normals[i]-Vector3(dx,0,dz)*normals[i].y).normalized()
 arrays[Mesh.ARRAY_VERTEX]=vertices
 arrays[Mesh.ARRAY_NORMAL]=normals
 var mesh:=ArrayMesh.new()
 mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES,arrays)
 return mesh

func settled_head_mesh() -> ArrayMesh:
 var surface:=SurfaceTool.new()
 surface.begin(Mesh.PRIMITIVE_TRIANGLES)
 var rows: Array[Vector3]=[
  Vector3(0.,1.49,-1.08),
  Vector3(.80,1.065,-.61),
  Vector3(.89,.875,-.51),
  Vector3(1.,.76,-.42),
 ]
 for row in range(rows.size()-1):
  for corner in [Vector2i(0,0),Vector2i(0,1),Vector2i(1,0),Vector2i(1,0),Vector2i(0,1),Vector2i(1,1)]:
   var profile:=rows[row+corner.y]
   surface.set_uv(Vector2(corner.x,profile.x))
   # Only the strip with the shoulders drops below the quilt.
   surface.add_vertex(Vector3(-.56+(float(corner.x)-.5)*.98,profile.y,profile.z))
 surface.generate_normals()
 return surface.commit()
