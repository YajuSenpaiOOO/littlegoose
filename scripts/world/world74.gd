extends "res://scripts/world/world73.gd"

func _build_lab_floor() -> void:
	super._build_lab_floor()
	meadow=preload("res://scripts/world/world_surface74.gd").new()

func _rail_script72() -> Script:
	return preload("res://scripts/art/rail_station74.gd")

func _time_script() -> Script:
	return preload("res://scripts/world/world_time74.gd")

func _build_map_panel() -> void:
	map_panel=preload("res://scripts/world/world_map74.gd").new()
	map_panel.surface=meadow;map_panel.actor=hero
	map_panel.z_index=100
	map_panel.position=Vector2(1165,20);map_panel.size=Vector2(410,322)
	label.get_parent().add_child(map_panel);map_panel.hide()

func _title35() -> void:
	DisplayServer.window_set_title("小白鹅 · 连续站区74 · 广场 / 后接铁路高地 / 前缘挡土墙")

func _ready() -> void:
	super._ready()
	while not is_instance_valid(rail72): await get_tree().physics_frame
	print("WORLD74_CONTINUOUS_STATION_TERRACE_READY")
