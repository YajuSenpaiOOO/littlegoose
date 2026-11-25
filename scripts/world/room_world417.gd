extends "res://scripts/world/room_world414.gd"
func room_script355() -> Script:return preload("res://scripts/room/room_shell417.gd")
func yard_script403() -> Script:return preload("res://scripts/room/home_yard417.gd")
func _ready() -> void:
 await super._ready()
 help367="417 · A半开放娃娃屋\n主厅 / 左床龛 / 右洗漱收纳\nWASD穿门 · F3进出 · F2昼夜\n宽木拱连接 · 沙漏暂不摆放"
 DisplayServer.window_set_title("小白鹅 · 417 · A半开放娃娃屋");refresh367()
