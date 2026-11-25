extends "res://scripts/room/room_shell360.gd"
var painted361:=true
var paint_materials361: Array[ShaderMaterial]=[]
var render_meshes361: Array[MeshInstance3D]=[]
var contact361: MeshInstance3D
func build_furniture() -> void:
 super.build_furniture()
 for n in bed360.find_children("*","MeshInstance3D",true,false):
  if not n.material_override is StandardMaterial3D:continue
  var source: StandardMaterial3D=n.material_override
  var m:=ShaderMaterial.new();m.shader=preload("res://scripts/room/painted_bed361.gdshader")
  m.set_shader_parameter("paint",source.albedo_texture)
  m.set_shader_parameter("tile_offset",Vector2(source.uv1_offset.x,source.uv1_offset.y))
  var linear:=source.albedo_color.srgb_to_linear()
  m.set_shader_parameter("tint",Vector3(linear.r,linear.g,linear.b))
  n.material_override=m;paint_materials361.append(m);render_meshes361.append(n)
 var plane:=PlaneMesh.new();plane.size=Vector2(2.95,3.35)
 var mat:=ShaderMaterial.new();mat.shader=preload("res://scripts/art/foot_contact16.gdshader")
 contact361=shape(bed360,plane,Vector3(0.,.012,0.),mat);contact361.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
 set_painted361(true)
func set_painted361(value: bool) -> void:
 painted361=value
 for m in paint_materials361:m.set_shader_parameter("painted",value)
 for n in render_meshes361:n.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF if value else GeometryInstance3D.SHADOW_CASTING_SETTING_ON
 contact361.visible=value
