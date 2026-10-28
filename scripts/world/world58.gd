extends "res://scripts/world/world57.gd"

func _porch_script() -> Script:
	return preload("res://scripts/art/day_fill58.gd")

func _time_script() -> Script:
	return preload("res://scripts/world/world_time58.gd")

func _title35() -> void:
	DisplayServer.window_set_title("小白鹅 · 纯聚光58 · Alt+B 仅聚光/仅随身补光/叠加 · Alt+4 夜晚")
