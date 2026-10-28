extends "res://scripts/world/world80.gd"
var station81: Node3D
func _rail_script72() -> Script: return preload("res://scripts/art/rail_station81.gd")
func _time_script() -> Script: return preload("res://scripts/world/world_time81.gd")
func _station_kit_script81() -> Script: return preload("res://scripts/art/station_kit81.gd")
func _title35() -> void:
	DisplayServer.window_set_title("小白鹅 · 车站81 · 候车厅 / 站台雨棚 / 静态车厢")
func _ready() -> void:
	super._ready()
	while not is_instance_valid(accents79): await get_tree().physics_frame
	station81=_station_kit_script81().new();station81.world=self;add_child(station81)
	time55.update_guide();_title35()
	print("WORLD81_PAINTED_STATION_READY")
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and event.ctrl_pressed and event.physical_keycode==KEY_5 and is_instance_valid(station81):
		_teleport15(meadow.landmarks.station+Vector2(-8.,2.));return
	super._unhandled_input(event)
