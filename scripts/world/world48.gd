extends "res://scripts/world/world47.gd"

func _rebuild_root_pieces() -> void:
	super._rebuild_root_pieces()
	if is_instance_valid(lighting47): lighting47._apply_frame_tint(lighting47.profile>0)

func _atmosphere_script() -> Script:
	return preload("res://scripts/art/woodland_atmosphere48.gd")

func _lighting_script() -> Script:
	return preload("res://scripts/art/light_profiles48.gd")

func _ready() -> void:
	super._ready()
	while not is_instance_valid(lighting47): await get_tree().physics_frame
	_title35()
	print("WORLD48_STAGE_AND_LOCAL_GLOW_READY")

func _title35() -> void:
	var selected := "舞台层次＋局部柔光"
	if is_instance_valid(lighting47): selected=lighting47.LABELS48[lighting47.profile]
	DisplayServer.window_set_title("小白鹅 · 舞台层次48 · %s · Ctrl+7 原版 / 8 层次 / 9 层次＋柔光"%selected)

func _status() -> void:
	super._status()
	if world_ready:
		label.text=label.text.replace("连续世界47","连续世界48")
		label.text=label.text.replace("Ctrl+7/8/9 原版/暖阳/薄雾","Ctrl+7/8/9 原版/层次/层次＋柔光")
