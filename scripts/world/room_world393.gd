extends "res://scripts/world/room_world392.gd"
func room_script355() -> Script:return preload("res://scripts/room/room_shell393.gd")
func _ready() -> void:
 await super._ready();DisplayServer.window_set_title("小白鹅 · 393 · 拱窗与绿格窗帘")
 help367="393 · 拱窗与绿格窗帘\nV新旧窗户 · Z壁纸 · X整墙/半墙\nWASD走动 · F2昼夜 · K地面对照\nN双人近看 · E床边睡起 · F3出门"
 refresh367()
func refresh367() -> void:
 if is_instance_valid(label367) and is_instance_valid(room):label367.text=help367+"\n当前："+("拱窗 / 绿格帘 / 窗台花" if room.use_window393 else "旧方窗 / 挡板")
func set_night355(value: bool) -> void:
 super.set_night355(value)
 if is_instance_valid(room) and is_instance_valid(room.garden_mat393):room.set_garden_night393(value)
func _input(event: InputEvent) -> void:
 if ready355 and event is InputEventKey and event.pressed and not event.echo and event.physical_keycode==KEY_V:
  room.set_window393(not room.use_window393);refresh367();get_viewport().set_input_as_handled();return
 super._input(event)
