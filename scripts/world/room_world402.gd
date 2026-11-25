extends "res://scripts/world/room_world400.gd"
var layout_ready402:=false
func room_script355() -> Script:return preload("res://scripts/room/room_shell402.gd")
func _ready() -> void:
 await super._ready();layout_ready402=true;camera402();reset355();set_follow363(true)
 DisplayServer.window_set_title("小白鹅 · 402 · 门口式空间布局")
 help367="402 · 门口式空间布局（色块占位）\n6新布局/原全屋 · WASD走动 · F12跟随\n4光照 · 5藤蔓 · F2昼夜\n1衣柜 · 2洗漱 · G书桌 · F3出门"
 refresh367()
func camera402() -> void:
 if not close398.is_empty():close_cabinet398("")
 close_desk395(false);close_tea396(false)
 if near372:set_pair372(false)
 var following: bool=follow363;set_follow363(false)
 camera.rotation_degrees=Vector3(-18. if room.compact402 else -25.,0,0);camera.fov=42.
 var at:=Vector3(0,.45,-1.6) if room.compact402 else Vector3(0,1.05,-.35)
 camera.global_position=at+camera.global_basis.z*(11.8 if room.compact402 else 17.8)
 camera_home363=camera.global_position;camera.reset_physics_interpolation();set_follow363(following)
func reset355() -> void:
 super.reset355()
 if layout_ready402 and room.compact402:
  hero.global_position=Vector3(0,.05,1.4);hero.reset_physics_interpolation()
  companion373.global_position=Vector3(1.,.05,1.4);companion373.reset_physics_interpolation()
 elif layout_ready402:
  companion373.global_position=Vector3(1.1,.05,2.8);companion373.reset_physics_interpolation()
func choose355() -> Dictionary:
 if is_instance_valid(room) and room.compact402 and Vector2(hero.position.x,hero.position.z).distance_to(Vector2(0,3.05))<.85:return {"id":"exit","title":"离开小屋"}
 return super.choose355()
func follow_target363() -> Vector3:
 if layout_ready402 and room.compact402:
  return camera_home363+Vector3(clampf(hero.position.x*.27,-1.6,1.6),0,clampf((hero.position.z-.5)*.10,-.12,.12))
 return super.follow_target363()
func refresh367() -> void:
 if is_instance_valid(label367) and is_instance_valid(room):label367.text=help367+"\n当前："+("收短纵深 / 前景箱篮 / 拱顶包边" if room.compact402 else "原400布局与全屋镜头")
func _process(delta: float) -> void:
 super._process(delta)
 if layout_ready402:follow_label363.text="镜头："+("入口18° / 42FOV · 限幅跟随" if room.compact402 else "原全屋25° / 42FOV")
func _input(event: InputEvent) -> void:
 if ready355 and event is InputEventKey and event.pressed and not event.echo:
  if event.physical_keycode==KEY_6:
   room.set_layout402(not room.compact402);camera402();reset355();companion373.ready373=false;companion373.setup373();refresh367();get_viewport().set_input_as_handled();return
  if event.physical_keycode==KEY_X:get_viewport().set_input_as_handled();return
 super._input(event)
