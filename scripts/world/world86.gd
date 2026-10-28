extends "res://scripts/world/world85.gd"
func _rail_script72() -> Script: return preload("res://scripts/art/rail_station86.gd")
func _time_script() -> Script: return preload("res://scripts/world/world_time86.gd")
func _title35() -> void: DisplayServer.window_set_title("小白鹅 · 86 · 实体墙顶 / 正午热意对照")
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and event.ctrl_pressed and event.alt_pressed and event.physical_keycode in [KEY_H,KEY_V,KEY_D] and is_instance_valid(time55):
		time55.handle_input(event);return
	super._unhandled_input(event)
