extends "res://scripts/world/room_world391.gd"
func room_script355() -> Script:return preload("res://scripts/room/room_shell392.gd")
func _ready() -> void:
 await super._ready();DisplayServer.window_set_title("小白鹅 · 392 · 整面侧墙与三款壁纸")
 help367="392 · 整面侧墙与三款壁纸\nZ壁纸抽卡 · X整墙/半墙对照\nWASD走动 · F2昼夜 · K地面对照\nE床边睡起 · F7归位 · F3出门"
 refresh367()
func refresh367() -> void:
 if is_instance_valid(label367) and is_instance_valid(room):label367.text=help367+"\n当前："+["A奶油花叶","B森林植物","C复古童话"][room.style392]+(" · 整侧墙" if room.full392 else " · 半侧墙")
func _input(event: InputEvent) -> void:
 if ready355 and event is InputEventKey and event.pressed and not event.echo:
  if event.physical_keycode==KEY_Z:room.set_style392(room.style392+1);refresh367();get_viewport().set_input_as_handled();return
  if event.physical_keycode==KEY_X:room.set_full392(not room.full392);refresh367();get_viewport().set_input_as_handled();return
 super._input(event)
