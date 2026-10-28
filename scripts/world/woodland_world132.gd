extends "res://scripts/world/woodland_world131.gd"
func _title35() -> void: DisplayServer.window_set_title("小白鹅 · 132 · 纸片交错 / 轻柔避让")
func _enemy_script() -> Script: return preload("res://scripts/combat/paper132.gd") if paper_trial129 else preload("res://scripts/combat/tuantuan128.gd")
