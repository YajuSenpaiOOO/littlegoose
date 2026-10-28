extends "res://scripts/world/world68.gd"

func _build_lab_floor() -> void:
	super._build_lab_floor()
	meadow=preload("res://scripts/world/world_surface69.gd").new()

func _lamp_shadow_script() -> Script:
	return preload("res://scripts/art/local_lamp_shadow69.gd")

func _time_script() -> Script:
	return preload("res://scripts/world/world_time69.gd")

func _ready() -> void:
	super._ready()
	while not is_instance_valid(local68): await get_tree().physics_frame
	if not "--combat" in OS.get_cmdline_user_args():
		_teleport15(meadow.landmarks.grove+Vector2(12,6))
		time55.preview_at(12.); time55.visual_hour=12.; time55.apply_look()
	time55.update_guide()
	print("WORLD69_TERRAIN_REHEARSAL_READY")

func _title35() -> void:
	DisplayServer.window_set_title("小白鹅 · 林路与站台69 · 地形草稿 / 灯影修正")
