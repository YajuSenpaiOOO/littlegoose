extends "res://scripts/world/world59.gd"

func _bridge_script() -> Script:
	return preload("res://scripts/art/bridge_lake60.gd")

func _time_script() -> Script:
	return preload("res://scripts/world/world_time60.gd")

func _title35() -> void:
	var selected := "流光湖水"
	if is_instance_valid(bridge59): selected=bridge59.BRIDGES[bridge59.bridge_style]+" · "+bridge59.WATERS[bridge59.water_style]
	DisplayServer.window_set_title("小白鹅 · 流光湖水60 · %s · Alt+G 波光 / Alt+M 动静"%selected)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and event.alt_pressed and is_instance_valid(bridge59):
		if event.physical_keycode in [KEY_5,KEY_6,KEY_7]:
			bridge59.set_bridge(event.physical_keycode-KEY_5)
			time55.update_guide()
			return
		if event.physical_keycode==KEY_G:
			bridge59.set_sparkles(not bridge59.sparkling)
			time55.update_guide()
			return
		if event.physical_keycode==KEY_M:
			bridge59.set_motion(not bridge59.moving)
			time55.update_guide()
			return
	super._unhandled_input(event)
