extends "res://scripts/world/world67.gd"
var local68: Node3D

func _ready() -> void:
	super._ready()
	while not is_instance_valid(frames66): await get_tree().physics_frame
	local68=_lamp_shadow_script().new()
	local68.world=self
	add_child(local68)
	if not "--combat" in OS.get_cmdline_user_args():
		var lamp: Vector3=woodland_life.lantern_root.global_position
		_teleport15(Vector2(lamp.x,lamp.z)+Vector2(1.45,1.25))
		time55.preview_at(22.); time55.visual_hour=22.; time55.apply_look()
	time55.update_guide()
	_title35()
	print("WORLD68_LOCAL_LAMP_SHADOW_READY")

func _lamp_shadow_script() -> Script:
	return preload("res://scripts/art/local_lamp_shadow68.gd")

func _time_script() -> Script:
	return preload("res://scripts/world/world_time68.gd")

func _title35() -> void:
	DisplayServer.window_set_title("小白鹅 · 灯下归途68 · 夜间灯影 · Alt+S 对照")

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and event.alt_pressed and event.physical_keycode==KEY_S and is_instance_valid(local68):
		local68.enabled=not local68.enabled
		time55.update_guide()
		return
	super._unhandled_input(event)
