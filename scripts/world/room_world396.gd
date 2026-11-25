extends "res://scripts/world/room_world395.gd"
var tea_close396:=false
var before_tea396:=Vector3.ZERO
func room_script355() -> Script:return preload("res://scripts/room/room_shell396.gd")
func _ready() -> void:
 await super._ready();DisplayServer.window_set_title("小白鹅 · 396 · 实体圆桌与软椅")
 help367="396 · 实体圆桌与软椅\nT实体/插画桌椅 · G书桌近看 · Y茶桌近看\nF12固定/跟随 · WASD走动 · F2昼夜\nV窗户 · E床睡起 · F3出门"
 refresh367()
func refresh367() -> void:
 if is_instance_valid(label367) and is_instance_valid(room):label367.text=help367+"\n当前："+("实体桌椅 / 曲面织物 / 独立茶具" if room.use_solids396 else "394整张插画对照")
func close_tea396(value: bool) -> void:
 if value==tea_close396:return
 tea_close396=value
 if value:
  close_desk395(false);before_tea396=camera.global_position;set_follow363(false)
  camera.global_position=Vector3(3.8,.78,1.9)+camera.global_basis.z*5.5
 else:camera.global_position=before_tea396
 camera.reset_physics_interpolation()
func _input(event: InputEvent) -> void:
 if ready355 and event is InputEventKey and event.pressed and not event.echo:
  if event.physical_keycode==KEY_T:
   room.set_solids396(not room.use_solids396);refresh367();get_viewport().set_input_as_handled();return
  if event.physical_keycode==KEY_Y:
   close_tea396(not tea_close396);get_viewport().set_input_as_handled();return
  if event.physical_keycode in [KEY_G,KEY_F12] and tea_close396:close_tea396(false)
 super._input(event)
