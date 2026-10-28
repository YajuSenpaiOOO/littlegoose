extends "res://scripts/world/world50.gd"
func _porch_script() -> Script:
	return preload("res://scripts/art/woodland_light_controller51.gd")

func _title35() -> void:
	var selected := "密度＋阳光开口"
	if is_instance_valid(porch49): selected=porch49.LABELS51[porch49.route_mode]
	DisplayServer.window_set_title("小白鹅 · 森林光影51 · %s · Ctrl+7 原50 / 8 树密度 / 9 密度＋开口 · Ctrl+F4 林路"%selected)

func _status() -> void:
	super._status()
	if world_ready:
		label.text=label.text.replace("林路光影50","森林光影51")
		label.text=label.text.replace("Ctrl+7/8/9 暖院原版/林路柔和/明暗交替","Ctrl+7/8/9 原50/树密度/密度＋阳光开口")
