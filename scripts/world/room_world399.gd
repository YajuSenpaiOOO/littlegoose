extends "res://scripts/world/room_world398.gd"
func room_script355() -> Script:return preload("res://scripts/room/room_shell399.gd")
func _ready() -> void:
 await super._ready();DisplayServer.window_set_title("小白鹅 · 399 · 弧梁与角撑")
 help367="399 · 弧梁与角撑\n3木结构新旧 · M柜台新旧\nWASD走动 · F12固定/跟随 · F2昼夜\n1衣柜 · 2洗漱 · G书桌 · F3出门"
 refresh367()
func refresh367() -> void:
 if is_instance_valid(label367) and is_instance_valid(room):label367.text=help367+"\n结构："+("拱形后墙 / 弧梁 / 两角支撑" if room.use_frame399 else "原平直墙顶")
func _input(event: InputEvent) -> void:
 if ready355 and event is InputEventKey and event.pressed and not event.echo and event.physical_keycode==KEY_3:
  room.set_frame399(not room.use_frame399);refresh367();get_viewport().set_input_as_handled();return
 super._input(event)
