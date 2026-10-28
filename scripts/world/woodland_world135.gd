extends "res://scripts/world/woodland_world134.gd"
func _title35() -> void: DisplayServer.window_set_title("小白鹅 · 135 · 左右鼓风 / 纸张落地")
func _enemy_script() -> Script: return preload("res://scripts/combat/paper135.gd") if paper_trial129 else preload("res://scripts/combat/tuantuan128.gd")
