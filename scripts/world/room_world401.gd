extends "res://scripts/world/room_world400.gd"
var view401:=0
const VIEWS401=[
 {"name":"A 原全屋","pitch":25.,"distance":17.8,"target":Vector3(0,1.05,-.35)},
 {"name":"B 推近 / 重心后移","pitch":25.,"distance":15.4,"target":Vector3(0,1.25,-1.15)},
 {"name":"C 低角度入口","pitch":20.,"distance":14.5,"target":Vector3(0,1.45,-1.5)}]
var ready401:=false
func _ready() -> void:
 await super._ready();ready401=true
 DisplayServer.window_set_title("小白鹅 · 401 · 三套镜头构图")
 help367="401 · 三套镜头构图（场景相同）\n6原全屋 · 7推近25° · 8入口20°\nWASD走动 · F12跟随 · F2昼夜\n4光照 · 5藤蔓 · F3出门"
 set_view401(0)
func set_view401(index: int) -> void:
 if not close398.is_empty():close_cabinet398("")
 close_desk395(false);close_tea396(false)
 if near372:set_pair372(false)
 var following: bool=follow363
 set_follow363(false)
 view401=posmod(index,3)
 var data: Dictionary=VIEWS401[view401]
 camera.rotation_degrees=Vector3(-data.pitch,0,0);camera.fov=42.
 camera.global_position=data.target+camera.global_basis.z*data.distance
 camera_home363=camera.global_position
 camera.reset_physics_interpolation();set_follow363(following);refresh367()
func refresh367() -> void:
 if is_instance_valid(label367):label367.text=help367+"\n镜头："+VIEWS401[view401].name
func _process(delta: float) -> void:
 super._process(delta)
 if ready401 and is_instance_valid(follow_label363):follow_label363.text="镜头："+VIEWS401[view401].name+(" · 跟随" if follow363 else " · 固定")+" · "+str(VIEWS401[view401].pitch)+"° / 42FOV"
func _input(event: InputEvent) -> void:
 if ready355 and event is InputEventKey and event.pressed and not event.echo and event.physical_keycode in [KEY_6,KEY_7,KEY_8]:
  set_view401(int(event.physical_keycode-KEY_6));get_viewport().set_input_as_handled();return
 super._input(event)
