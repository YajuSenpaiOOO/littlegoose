extends "res://scripts/world/woodland_world132.gd"
func _title35() -> void: DisplayServer.window_set_title("小白鹅 · 134 · 撕页轻摆 / 鼓风 >ω<")
func _enemy_script() -> Script: return preload("res://scripts/combat/paper134.gd") if paper_trial129 else preload("res://scripts/combat/tuantuan128.gd")
