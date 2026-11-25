extends "res://scripts/world/room_world414.gd"
func yard_script403() -> Script:return preload("res://scripts/room/home_yard415.gd")
func _ready() -> void:
 await super._ready()
 help367="415 · 主屋 / 侧屋 / 入口体块对照\nWASD穿门 · F3进出 · F2昼夜\n近镜与内拱架保持 · 纹理尚未细化"
 DisplayServer.window_set_title("小白鹅 · 415 · 木屋主次体块")
 refresh367()
