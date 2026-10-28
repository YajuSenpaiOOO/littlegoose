extends "res://scripts/world/world74.gd"
func _build_lab_floor() -> void:
	super._build_lab_floor()
	meadow=preload("res://scripts/world/world_surface75.gd").new()
func _rail_script72() -> Script:
	return preload("res://scripts/art/rail_station75.gd")
func _time_script() -> Script:
	return preload("res://scripts/world/world_time75.gd")
func _grass_allowed19(at: Vector2) -> bool:
	if at.x>3.0 and at.x<11.5 and absf(at.y-meadow.SIDE_FOOT75.y)<1.8: return false
	return super._grass_allowed19(at)
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and not event.alt_pressed and not event.ctrl_pressed and event.physical_keycode==KEY_0:
		set_review72(false);_teleport15(meadow.SIDE_FOOT75+Vector2(1.,2.));return
	super._unhandled_input(event)
func _title35() -> void:
	DisplayServer.window_set_title("小白鹅 · 站区纵深75 · 短阶 / 侧向石阶 / 铁路到边界")
func _ready() -> void:
	super._ready()
	while not is_instance_valid(rail72): await get_tree().physics_frame
	print("WORLD75_STATION_DEPTH_AND_SIDE_STEPS_READY")
