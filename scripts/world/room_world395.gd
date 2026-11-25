extends "res://scripts/world/room_world394.gd"
var desk_close395:=false
var before_close395:=Vector3.ZERO
func room_script355() -> Script:return preload("res://scripts/room/room_shell395.gd")
func _ready() -> void:
 await super._ready();DisplayServer.window_set_title("小白鹅 · 395 · 实体手绘书桌样件")
 help367="395 · 实体手绘书桌样件\nT实体/插画书桌 · G书桌近看\nF12固定/跟随 · WASD走动 · F2昼夜\nV窗户 · E床睡起 · F3出门"
 refresh367()
func refresh367() -> void:
 if is_instance_valid(label367) and is_instance_valid(room):label367.text=help367+"\n当前："+("3D结构 / 分面手绘纹理" if room.use_desk395 else "394整张插画对照")
func close_desk395(value: bool) -> void:
 if value==desk_close395:return
 desk_close395=value
 if value:
  before_close395=camera.global_position;set_follow363(false)
  camera.global_position=Vector3(-.5,1.05,-3.)+camera.global_basis.z*6.5
 else:camera.global_position=before_close395
 camera.reset_physics_interpolation()
func _input(event: InputEvent) -> void:
 if ready355 and event is InputEventKey and event.pressed and not event.echo:
  if event.physical_keycode==KEY_T:
   room.set_desk395(not room.use_desk395);refresh367();get_viewport().set_input_as_handled();return
  if event.physical_keycode==KEY_G:
   close_desk395(not desk_close395);get_viewport().set_input_as_handled();return
  if event.physical_keycode==KEY_F12 and desk_close395:close_desk395(false)
 super._input(event)
