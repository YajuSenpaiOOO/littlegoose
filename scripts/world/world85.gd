extends "res://scripts/world/world84.gd"
func _build_lab_floor() -> void:
	super._build_lab_floor();meadow=preload("res://scripts/world/world_surface85.gd").new()
func _rail_script72() -> Script: return preload("res://scripts/art/rail_station85.gd")
func _time_script() -> Script: return preload("res://scripts/world/world_time85.gd")
func _title35() -> void: DisplayServer.window_set_title("小白鹅 · 85 · 墙阶碰撞 / 清凉日荫")
func _unhandled_input(event: InputEvent) -> void:
	# Consume this before the older Alt+N sign comparison handler.
	if event is InputEventKey and event.pressed and not event.echo and event.ctrl_pressed and event.alt_pressed and event.physical_keycode==KEY_N and is_instance_valid(time55):
		time55.handle_input(event);return
	super._unhandled_input(event)
