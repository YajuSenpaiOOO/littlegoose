extends "res://scripts/world/world62.gd"

func _build_lab_floor() -> void:
	super._build_lab_floor()
	meadow=preload("res://scripts/world/world_surface63.gd").new()

func _landmark_script() -> Script:
	return preload("res://scripts/art/landmark_studies63.gd")

func _time_script() -> Script:
	return preload("res://scripts/world/world_time63.gd")

func _junction_sign_position() -> Vector2:
	return meadow.landmarks.junction+Vector2(2.3,10.2)

func go_tree62() -> void:
	if combat_ready: _leave_encounter()
	_teleport15(meadow.landmarks.junction+Vector2(0,12.5))
	if is_instance_valid(landmark62): landmark62.start_review()

func _title35() -> void:
	var selected := "轻像素古树"
	if is_instance_valid(landmark62): selected=landmark62.LABELS[landmark62.variant] if not landmark62.old_tree else "旧占位树"
	DisplayServer.window_set_title("小白鹅 · 古树与环路63 · %s · Alt+5/6/7 · Alt+N 路牌"%selected)
