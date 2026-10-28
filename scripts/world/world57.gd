extends "res://scripts/world/world56.gd"

func _porch_script() -> Script:
	return preload("res://scripts/art/day_fill57.gd")

func _time_script() -> Script:
	return preload("res://scripts/world/world_time57.gd")

func _title35() -> void:
	DisplayServer.window_set_title("小白鹅 · 夜幕舞台57 · Alt+1/2/3/4 晨午暮夜 · Alt+F 萤火虫 · Alt+L 聚光 · Alt+H 远景柔化")
