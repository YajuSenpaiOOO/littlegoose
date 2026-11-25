extends "res://scripts/room/room_shell365.gd"
const QUILT366=preload("res://scripts/room/quilt_mesh366.gd")
var covers366: Node3D
var duvet_mesh366: MeshInstance3D
var throw_mesh366: MeshInstance3D
var show_duvet366:=true
var show_throw366:=true
func build_furniture() -> void:
 super.build_furniture()
 covers366=Node3D.new();covers366.name="SeparateDuvetAndSageThrow366";craft364.add_child(covers366)
 duvet_mesh366=shape(covers366,QUILT366.mesh366(0),Vector3.ZERO,quilt_material366("cream_duvet.png",Color("ecdbc1")));duvet_mesh366.name="ThickCreamDuvet";duvet_mesh366.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
 throw_mesh366=shape(covers366,QUILT366.mesh366(1),Vector3.ZERO,quilt_material366("sage_throw.png",Color("929467")));throw_mesh366.name="ThinSageThrow";throw_mesh366.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
 update_covers366()
func quilt_material366(file: String,plain: Color) -> ShaderMaterial:
 var m:=ShaderMaterial.new();m.shader=preload("res://scripts/room/painted_linen365.gdshader");m.set_shader_parameter("paint",source356("res://assets/room366/"+file));m.set_shader_parameter("plain_color",Vector3(plain.r,plain.g,plain.b));craft_mats364.append(m);return m
func update_covers366() -> void:
 if not is_instance_valid(duvet_mesh366):return
 duvet_mesh366.visible=show_duvet366;throw_mesh366.visible=show_duvet366 and show_throw366
