extends "res://scripts/world/world81.gd"
func _rail_script72() -> Script: return preload("res://scripts/art/rail_station82.gd")
func _station_kit_script81() -> Script: return preload("res://scripts/art/station_kit82.gd")
func _time_script() -> Script: return preload("res://scripts/world/world_time82.gd")
func _title35() -> void:
	DisplayServer.window_set_title("小白鹅 · 车站82 · 中置候车厅 / 横向站台 / 落地雨棚")
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and event.ctrl_pressed and event.physical_keycode==KEY_5:
		_teleport15(meadow.landmarks.station+Vector2(0,2.));return
	super._unhandled_input(event)
