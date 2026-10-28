extends "res://scripts/world/world60.gd"

func _bridge_script() -> Script:
	return preload("res://scripts/art/bridge_lake61.gd")

func _time_script() -> Script:
	return preload("res://scripts/world/world_time61.gd")

func _title35() -> void:
	var selected := "绳桥 · 绘本水"
	if is_instance_valid(bridge59): selected=bridge59.BRIDGES[bridge59.bridge_style]+" · "+bridge59.WATERS[bridge59.water_style]
	DisplayServer.window_set_title("小白鹅 · 远水柔光61 · %s · Alt+V 远水柔光"%selected)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and event.alt_pressed and event.physical_keycode==KEY_V and is_instance_valid(bridge59):
		bridge59.set_distant_glow(not bridge59.distant_glow)
		time55.update_guide()
		return
	super._unhandled_input(event)
