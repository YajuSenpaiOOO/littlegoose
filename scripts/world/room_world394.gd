extends "res://scripts/world/room_world393.gd"
func room_script355() -> Script:return preload("res://scripts/room/room_shell394.gd")
func _ready() -> void:
 await super._ready();DisplayServer.window_set_title("小白鹅 · 394 · 手绘书桌与茶桌")
 help367="394 · 手绘书桌与茶桌\nT桌椅新旧 · V窗户 · Z壁纸\nWASD走动 · F2昼夜 · N双人近看\nE床边睡起 · F7归位 · F3出门"
 refresh367()
func refresh367() -> void:
 if is_instance_valid(label367) and is_instance_valid(room):label367.text=help367+"\n当前："+("手绘桌椅 / 书本文具 / 双人茶具" if room.use_furniture394 else "旧桌椅对照")
func _input(event: InputEvent) -> void:
 if ready355 and event is InputEventKey and event.pressed and not event.echo and event.physical_keycode==KEY_T:
  room.set_furniture394(not room.use_furniture394);refresh367();get_viewport().set_input_as_handled();return
 super._input(event)
