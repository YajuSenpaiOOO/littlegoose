extends "res://scripts/room/room_shell368.gd"
const SLEEP369=preload("res://scripts/room/sleep_mesh369.gd")
var sleep_root369: Node3D
var head369: MeshInstance3D
var body369: MeshInstance3D
var pose_material369: ShaderMaterial
var old_pose369:=false
var old_duvet369: ArrayMesh
var old_throw369: ArrayMesh
var new_duvet369: ArrayMesh
var new_throw369: ArrayMesh
func build_furniture() -> void:
 super.build_furniture()
 old_duvet369=occupied_duvet368;old_throw369=occupied_throw368
 new_duvet369=SLEEP369.cover369(old_duvet369);new_throw369=SLEEP369.cover369(old_throw369)
 sleep_root369=Node3D.new();sleep_root369.name="CompactPixelSleep369";craft364.add_child(sleep_root369)
 pose_material369=ShaderMaterial.new();pose_material369.shader=preload("res://scripts/room/sleep_pose369.gdshader")
 pose_material369.set_shader_parameter("pose",source356("res://assets/room369/sleep_full_pixel.png"))
 head369=shape(sleep_root369,SLEEP369.mesh369(0.,.52),Vector3.ZERO,pose_material369);head369.name="PillowHeadHair369"
 body369=shape(sleep_root369,SLEEP369.mesh369(.52,1.),Vector3.ZERO,pose_material369);body369.name="FullBodyUnderCover369"
 head369.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF;body369.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
 set_occupied368(false)
func set_occupied368(value: bool) -> void:
 if new_duvet369!=null:
  occupied_duvet368=old_duvet369 if old_pose369 else new_duvet369
  occupied_throw368=old_throw369 if old_pose369 else new_throw369
 super.set_occupied368(value)
 if not is_instance_valid(sleep_root369):return
 sleep_actor368.visible=value and old_pose369
 sleep_root369.visible=value and not old_pose369
func set_old_pose369(value: bool) -> void:
 old_pose369=value;set_occupied368(occupied368)
func _process(delta: float) -> void:
 super._process(delta)
 if not is_instance_valid(pose_material369):return
 var phase:=clampf(inverse_lerp(.42,.70,world.environment.ambient_light_energy),0.,1.)
 var tint:=Vector3(.39,.40,.49).lerp(Vector3(.80,.80,.81),phase)
 for lamp in lamps362:
  if not lamp.visible or lamp.light_energy<=0.:continue
  var distance: float=lamp.global_position.distance_to(pillow364.global_position)
  tint+=Vector3(.055,.026,.005)*clampf(1.-distance/lamp.omni_range,0.,1.)*lamp.light_energy
 pose_material369.set_shader_parameter("room_tint",tint)
 pose_material369.set_shader_parameter("breathe",.0015*sin(breath_time368*1.7) if occupied368 else 0.)
