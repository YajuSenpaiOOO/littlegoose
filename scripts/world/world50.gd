extends "res://scripts/world/world49.gd"

func _porch_script() -> Script:
	return preload("res://scripts/art/route_light_controller50.gd")

func _title35() -> void:
	var selected := "林路明暗交替"
	if is_instance_valid(porch49): selected=porch49.LABELS50[porch49.route_mode]
	DisplayServer.window_set_title("小白鹅 · 林路光影50 · %s · Ctrl+7 暖院原版 / 8 柔和 / 9 明暗交替 · Ctrl+F4 林路"%selected)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and event.ctrl_pressed and event.physical_keycode==KEY_F4:
		_travel_region("trail")
		return
	super._unhandled_input(event)

func _status() -> void:
	super._status()
	if world_ready:
		label.text=label.text.replace("暖院样板49","林路光影50")
		label.text=label.text.replace("Ctrl+7/8/9 48原版/檐下暗部/林荫暖院","Ctrl+7/8/9 暖院原版/林路柔和/明暗交替 · Ctrl+F4 林路")
