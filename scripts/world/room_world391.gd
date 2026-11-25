extends "res://scripts/world/room_world376.gd"
func room_script355() -> Script:return preload("res://scripts/room/room_shell391.gd")
func _ready() -> void:
 await super._ready()
 DisplayServer.window_set_title("小白鹅 · 391 · 手绘木地板与织毯")
 help367="391 · 手绘木地板与织毯\nWASD走动 · K新旧地面对照\nF2昼夜 · L补光 · N双人近看\nJ小黑鹅跟随/等候 · H到地毯\nE床边睡起 · F7归位 · F3出门"
 refresh367()
func refresh367() -> void:
 if is_instance_valid(label367) and is_instance_valid(room):
  label367.text=help367+"\n当前："+("手绘木板 / 灰绿织毯" if room.use_ground391 else "原地板 / 原几何地毯")
func _input(event: InputEvent) -> void:
 if ready355 and event is InputEventKey and event.pressed and not event.echo and event.physical_keycode==KEY_K:
  room.set_ground391(not room.use_ground391);refresh367();get_viewport().set_input_as_handled();return
 super._input(event)
