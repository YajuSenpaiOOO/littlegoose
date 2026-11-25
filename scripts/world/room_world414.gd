extends "res://scripts/world/room_world412.gd"
func yard_script403() -> Script:return preload("res://scripts/room/home_yard414.gd")
func apply_zone410() -> void:
 super.apply_zone410()
 if ready410 and is_instance_valid(yard403.inside_roof413):yard403.inside_roof413.hide()
func _ready() -> void:
 await super._ready();apply_zone410()
 help367="414 · 石基 / 深窗套 / 木梁与深檐\nWASD穿门 · F3进出 · F2昼夜\n近景保持 · 室内恢复木拱架\n二楼暂缓 · 小院摆件未搬"
 DisplayServer.window_set_title("小白鹅 · 414 · 木屋分层装修")
 refresh367()
