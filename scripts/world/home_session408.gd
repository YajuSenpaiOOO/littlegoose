extends "res://scripts/world/home_session407.gd"
var poses408: Array=[]
func _ready() -> void:
 await super._ready();hint406.text="408 · 屋外到屋内 / 黑屏跨门\n门前E进屋 · F3快捷进出 · WASD走动"
 DisplayServer.window_set_title("小白鹅 · 408 · 屋外到屋内镜头 / 黑屏跨门")
func outside408() -> Camera3D:
 if not is_instance_valid(outside_camera407):outside_camera407=Camera3D.new();outside406.add_child(outside_camera407)
 outside_camera407.fov=map406.camera.fov;outside_camera407.near=map406.camera.near;outside_camera407.far=map406.camera.far
 return outside_camera407
func pose408(pose: Transform3D,angle: float) -> Transform3D:
 return Transform3D(Basis.from_euler(Vector3(deg_to_rad(-angle),0,0)),pose.origin)
func motion408(camera: Camera3D,target: Transform3D,duration: float) -> void:
 motion407=create_tween();motion407.set_trans(Tween.TRANS_SINE);motion407.set_ease(Tween.EASE_IN_OUT);motion407.tween_property(camera,"global_transform",target,duration)
func transition406(value: bool) -> void:
 if not ready406 or busy406 or indoors406==value:return
 busy406=true;map406.hero.controls_enabled=false;room406.hero.controls_enabled=false
 if is_instance_valid(motion407):motion407.kill()
 var source: Camera3D
 if value:
  source=outside408();source.global_transform=map406.camera.global_transform;map406.follow_camera=false;source.make_current()
 else:
  source=room406.camera;var before:=source.global_transform;room406.set_follow363(false);source.global_transform=before
 var crossing:=pose408(source.global_transform,22.)
 crossing.origin+=source.global_basis.z*(-2. if value else 1.5)
 motion408(source,crossing,.62)
 # Start the camera journey while the source scene is still fully visible.
 await get_tree().create_timer(.32).timeout
 var fade:=create_tween();fade.tween_property(curtain406,"color:a",1.,.30);await fade.finished
 if is_instance_valid(motion407):motion407.kill()
 indoors406=value;swaps406+=1
 if not value and room406.sleeping362:room406.set_sleep362(0)
 map406.process_mode=Node.PROCESS_MODE_DISABLED if value else Node.PROCESS_MODE_INHERIT
 room406.process_mode=Node.PROCESS_MODE_INHERIT if value else Node.PROCESS_MODE_DISABLED
 outside406.render_target_update_mode=SubViewport.UPDATE_DISABLED if value else SubViewport.UPDATE_ALWAYS
 inside406.render_target_update_mode=SubViewport.UPDATE_ALWAYS if value else SubViewport.UPDATE_DISABLED
 var target: Transform3D
 var destination: Camera3D
 if value:
  hour407=map406.time55.visual_hour;room406.set_night355(hour407>18.);room406.reset355();room406.camera403(false);room406.set_follow363(false)
  destination=room406.camera;target=destination.global_transform
  var start:=pose408(target,22.);start.origin+=target.basis.z*1.5
  destination.global_transform=start
 else:
  var hour: float=hour407 if room406.night355==(hour407>18.) else (20. if room406.night355 else 10.)
  map406.time55.preview_at(hour);map406.follow_camera=true;map406._teleport15(return_point406());map406.hero.velocity=Vector3.ZERO
  target=map406.camera.global_transform;map406.follow_camera=false;destination=outside408()
  var start:=pose408(target,22.);start.origin-=target.basis.z*2.
  destination.global_transform=start
 view406.texture=inside406.get_texture() if value else outside406.get_texture();destination.make_current();hint406.visible=not value
 poses408.append({"inside":value,"source_pitch":rad_to_deg(crossing.basis.get_euler().x),"destination_pitch":destination.rotation_degrees.x,"black_alpha":curtain406.color.a})
 print("HOME408_REBASE ",poses408[-1])
 await get_tree().process_frame;await get_tree().process_frame
 motion408(destination,target,.70)
 fade=create_tween();fade.tween_property(curtain406,"color:a",0.,.30);await fade.finished
 await motion407.finished
 if value:room406.set_follow363(room406.follow_preferred403)
 else:map406.follow_camera=true;map406.camera.make_current()
 map406.hero.controls_enabled=not value;room406.hero.controls_enabled=value;busy406=false
