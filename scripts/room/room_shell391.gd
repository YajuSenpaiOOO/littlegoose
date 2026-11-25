extends "res://scripts/room/room_shell375.gd"
var floor391: MeshInstance3D
var rug391: MeshInstance3D
var original_floor391: Material
var original_rug391: Material
var original_rug_mesh391: Mesh
var painted_floor391: ShaderMaterial
var painted_rug391: ShaderMaterial
var painted_rug_mesh391: PlaneMesh
var use_ground391:=true
func build_shell() -> void:
 super.build_shell()
 for child in get_children():
  if not child is MeshInstance3D or not child.material_override is ShaderMaterial:continue
  if child.material_override.shader==preload("res://scripts/room/floor355.gdshader"):floor391=child
  elif child.material_override.shader==preload("res://scripts/room/rug355.gdshader"):rug391=child
 original_floor391=floor391.material_override;original_rug391=rug391.material_override;original_rug_mesh391=rug391.mesh
 painted_floor391=ShaderMaterial.new();painted_floor391.shader=preload("res://scripts/room/floor391.gdshader")
 painted_floor391.set_shader_parameter("painted_wood",preload("res://assets/room391/floor.png"))
 painted_rug391=ShaderMaterial.new();painted_rug391.shader=preload("res://scripts/room/rug391.gdshader")
 painted_rug391.set_shader_parameter("painted_fabric",preload("res://assets/room391/rug.png"))
 painted_rug_mesh391=PlaneMesh.new();painted_rug_mesh391.size=Vector2(5.0,5.0*641.0/1317.0)
 floor391.name="PaintedWoodFloor391";rug391.name="WovenSageRug391"
 floor391.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
 rug391.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
 set_ground391(true)
func set_ground391(value: bool) -> void:
 use_ground391=value
 floor391.material_override=painted_floor391 if value else original_floor391
 rug391.material_override=painted_rug391 if value else original_rug391
 rug391.mesh=painted_rug_mesh391 if value else original_rug_mesh391
