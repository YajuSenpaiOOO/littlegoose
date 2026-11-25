extends "res://scripts/world/room_world402.gd"
var home_ready403:=false
var yard_built403:=false
var inside403:=false
var moving_camera403:=false
var yard403: Node3D
var transitions403: Array=[]
var room_build_ms403:=0
var yard_build_ms403:=0
var camera_tween403: Tween
var follow_preferred403:=true
func room_script355() -> Script:return preload("res://scripts/room/room_shell403.gd")
func companion_script373() -> Script:return preload("res://scripts/combat/goose_follow403.gd")
func yard_script403() -> Script:return preload("res://scripts/room/home_yard403.gd")
func _ready() -> void:
 var at:=Time.get_ticks_msec()
 await super._ready();room_build_ms403=Time.get_ticks_msec()-at
 at=Time.get_ticks_msec();yard403=yard_script403().new();add_child(yard403);yard403.build403(room)
 yard_build_ms403=Time.get_ticks_msec()-at;yard_built403=true
 while not companion373.ready373:await get_tree().physics_frame
 home_ready403=true;inside403=false;hero.controls_enabled=true
 reset355();camera403(false);apply400()
 DisplayServer.window_set_title("小白鹅 · 403 · 家园连续进出屋")
 help367="403 · 家园连续进出屋\nWASD走过门槛 · E进屋/查看\nF3进出屋 · F2昼夜 · F12镜头跟随\n屋内：1衣柜 · 2洗漱 · G书桌\n局部院子试演，尚未接森林/工坊"
 refresh367()
 print("HOME403_BUILT ",JSON.stringify({"room_ms":room_build_ms403,"yard_ms":yard_build_ms403,"node_count":get_tree().get_node_count()}))
 print("HOME403_SOURCE_TIMES ",JSON.stringify(room.source_times403))
func reset355() -> void:
 super.reset355()
 if home_ready403 and not inside403:
  hero.global_position=Vector3(0,.05,6.5);hero.reset_physics_interpolation()
  companion373.global_position=Vector3(1.,.05,6.5);companion373.reset_physics_interpolation();companion373.resume373()
func camera_target403(value: bool) -> Transform3D:
 var basis:=Basis.from_euler(Vector3(deg_to_rad(-18. if value else -25.),0,0))
 var target:=Vector3(0,.85,-1.9) if value else Vector3(0,.9,5.0)
 return Transform3D(basis,target+basis.z*(10.9 if value else 18.))
func camera403(animate: bool=true) -> void:
 if not close398.is_empty():close_cabinet398("")
 close_desk395(false);close_tea396(false)
 if near372:set_pair372(false)
 if is_instance_valid(camera_tween403):camera_tween403.kill()
 var before: Transform3D=camera.global_transform
 set_follow363(false);camera.global_transform=before;camera.fov=42.
 var target:=camera_target403(inside403);camera_home363=target.origin
 if animate:
  moving_camera403=true
  camera_tween403=create_tween();camera_tween403.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
  camera_tween403.tween_property(camera,"global_transform",target,.85)
  camera_tween403.tween_callback(finish_camera403)
 else:camera.global_transform=target;camera.reset_physics_interpolation();finish_camera403()
func finish_camera403() -> void:
 moving_camera403=false;set_follow363(follow_preferred403)
 yard403.facade403.visible=not inside403
func switch_zone403(value: bool,animate: bool=true) -> void:
 if not home_ready403 or inside403==value:return
 inside403=value
 if value:yard403.facade403.hide()
 camera403(animate);apply400();refresh367()
 var row:={"inside":value,"ms":Time.get_ticks_msec(),"node_count":get_tree().get_node_count(),"static_MB":Performance.get_monitor(Performance.MEMORY_STATIC)/1048576.}
 transitions403.append(row);print("HOME403_CROSS ",JSON.stringify(row))
func leave371() -> void:
 if not home_ready403 or moving_camera403:return
 if sleeping362:set_sleep362(0)
 hero.global_position=Vector3(0,.05,3.65);hero.velocity=Vector3.ZERO;hero.reset_physics_interpolation()
 switch_zone403(false)
func enter403() -> void:
 if not home_ready403 or moving_camera403:return
 hero.global_position=Vector3(0,.05,1.9);hero.velocity=Vector3.ZERO;hero.reset_physics_interpolation()
 switch_zone403(true)
func choose355() -> Dictionary:
 if home_ready403 and not inside403:
  if Vector2(hero.position.x,hero.position.z).distance_to(Vector2(0,3.25))<1.6:return {"id":"enter403","title":"走进小屋"}
  return {}
 return super.choose355()
func interact355() -> void:
 if home_ready403 and not inside403:
  if not choose355().is_empty():enter403()
  return
 super.interact355()
func apply400() -> void:
 super.apply400()
 if not home_ready403:return
 environment.background_color=Color("292522") if inside403 else (Color("273748") if night355 else Color("b4c3a0"))
 if not inside403:
  sun.light_energy=.055 if night355 else .65;environment.ambient_light_energy=.34 if night355 else .62
  window400.light_energy=0.
func follow_target363() -> Vector3:
 if not home_ready403:return super.follow_target363()
 if inside403:return camera_home363+Vector3(clampf(hero.position.x*.4,-2.2,2.2),0,clampf((hero.position.z-.5)*.07,-.10,.10))
 return camera_home363+Vector3(clampf(hero.position.x*.45,-2.8,2.8),0,clampf((hero.position.z-6.5)*.45,-.5,3.5))
func _process(delta: float) -> void:
 super._process(delta)
 if not home_ready403:
  if is_instance_valid(hero):hero.controls_enabled=false
  return
 if not inside403 and hero.position.z<2.15:switch_zone403(true)
 elif inside403 and hero.position.z>3.3:switch_zone403(false)
 follow_label363.text="镜头："+("入屋运镜" if moving_camera403 else ("室内18°" if inside403 else "小院25°"))
 if not inside403 and Vector2(hero.position.x,hero.position.z).distance_to(Vector2(0,16.))<2.:prompt.text="院外区域暂未接入 · 本轮只试家园往返"
func refresh367() -> void:
 if is_instance_valid(label367) and home_ready403:label367.text=help367+"\n当前："+("屋内" if inside403 else "门前小院")+" · 共用角色/场景"
func _input(event: InputEvent) -> void:
 if home_ready403 and event is InputEventKey and event.pressed and not event.echo:
  if event.physical_keycode==KEY_F3:
   if inside403:leave371()
   else:enter403()
   get_viewport().set_input_as_handled();return
  if event.physical_keycode==KEY_6:
   get_viewport().set_input_as_handled();return
  if event.physical_keycode==KEY_F12:
   if not moving_camera403:super._input(event);follow_preferred403=follow363
   get_viewport().set_input_as_handled();return
  if not inside403 and event.physical_keycode not in [KEY_E,KEY_F1,KEY_F2,KEY_F7,KEY_F12,KEY_J,KEY_O]:
   return
 super._input(event)
