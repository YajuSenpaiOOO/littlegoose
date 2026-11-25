extends "res://scripts/world/home_session406.gd"
var motion407: Tween
var hour407:=10.
var outside_camera407: Camera3D
func room_path406() -> String:return "res://scripts/world/room_world407.gd"
func _ready() -> void:
 await super._ready()
 hint406.text="407 · 双向运镜 / 门槛切面\n门前E进屋 · F3快捷进出 · WASD走动"
 DisplayServer.window_set_title("小白鹅 · 407 · 双向运镜与门槛切面")
func arrival407(target: Transform3D,indoor: bool) -> void:
 if not indoor and not is_instance_valid(outside_camera407):
  outside_camera407=Camera3D.new();outside406.add_child(outside_camera407)
  outside_camera407.fov=map406.camera.fov;outside_camera407.near=map406.camera.near;outside_camera407.far=map406.camera.far
 var camera: Camera3D=room406.camera if indoor else outside_camera407
 camera.global_transform=target
 if indoor:
  var basis:=Basis.from_euler(Vector3(deg_to_rad(-10.),0,0))
  camera.global_transform=Transform3D(basis,Vector3(0,.65,-1.4)+basis.z*13.1)
 else:
  camera.global_position=target.origin-target.basis.z*2.+Vector3.UP*.55
  camera.rotation_degrees.x=-34.
 motion407=create_tween();motion407.set_trans(Tween.TRANS_SINE);motion407.set_ease(Tween.EASE_IN_OUT)
 motion407.tween_property(camera,"global_transform",target,1.10)
 motion407.tween_callback(func():
  if indoor:room406.set_follow363(room406.follow_preferred403)
  else:map406.follow_camera=true;map406.camera.make_current())
func transition406(value: bool) -> void:
 if not ready406 or busy406 or indoors406==value:return
 busy406=true;map406.hero.controls_enabled=false;room406.hero.controls_enabled=false
 if is_instance_valid(motion407):motion407.kill()
 if indoors406:
  var before: Transform3D=room406.camera.global_transform
  room406.set_follow363(false)
  room406.camera.global_transform=before
  var retreat:=create_tween();retreat.tween_property(room406.camera,"position",room406.camera.position+room406.camera.global_basis.z*1.0,.24)
 else:map406.follow_camera=false
 var fade:=create_tween();fade.tween_property(curtain406,"color:a",1.,.26);await fade.finished
 indoors406=value;swaps406+=1
 if not value and room406.sleeping362:room406.set_sleep362(0)
 map406.process_mode=Node.PROCESS_MODE_DISABLED if value else Node.PROCESS_MODE_INHERIT
 room406.process_mode=Node.PROCESS_MODE_INHERIT if value else Node.PROCESS_MODE_DISABLED
 outside406.render_target_update_mode=SubViewport.UPDATE_DISABLED if value else SubViewport.UPDATE_ALWAYS
 inside406.render_target_update_mode=SubViewport.UPDATE_ALWAYS if value else SubViewport.UPDATE_DISABLED
 if value:
  hour407=map406.time55.visual_hour;room406.set_night355(hour407>18.);room406.reset355();room406.camera403(false);room406.set_follow363(false)
  arrival407(room406.camera.global_transform,true)
 else:
  var hour: float=hour407 if room406.night355==(hour407>18.) else (20. if room406.night355 else 10.)
  map406.time55.preview_at(hour);map406.follow_camera=true;map406._teleport15(Vector2(-4.7,-2.6));map406.hero.velocity=Vector3.ZERO
  var target: Transform3D=map406.camera.global_transform;map406.follow_camera=false;arrival407(target,false)
 view406.texture=inside406.get_texture() if value else outside406.get_texture()
 (room406.camera if value else outside_camera407).make_current();hint406.visible=not value
 print("HOME407_BLACK_SWITCH alpha=",curtain406.color.a)
 await get_tree().process_frame;await get_tree().process_frame
 fade=create_tween();fade.tween_property(curtain406,"color:a",0.,.34);await fade.finished
 map406.hero.controls_enabled=not value;room406.hero.controls_enabled=value;busy406=false
 print("HOME407_CROSS ",swaps406," indoors=",value)
