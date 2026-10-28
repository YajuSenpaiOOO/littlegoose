extends "res://scripts/world/world76.gd"

func _build_lab_floor() -> void:
	super._build_lab_floor()
	meadow=preload("res://scripts/world/world_surface77.gd").new()
func _roadside_wall_script76() -> Script: return preload("res://scripts/art/roadside_wall77.gd")
func _time_script() -> Script: return preload("res://scripts/world/world_time77.gd")

func _grass_road_distance19(at: Vector2) -> float:
	var distance: float=super._grass_road_distance19(at)
	return lerpf(maxf(distance,1.3),distance,meadow.road_finish77(at))

func _assign_ground_materials() -> void:
	super._assign_ground_materials()
	var shader := preload("res://scripts/art/world_ground77.gdshader")
	var endings := PackedVector4Array(meadow.road_endings77);endings.resize(8)
	for material in ground_materials:
		material.shader=shader
		material.set_shader_parameter("paint",ground_templates[3].get_shader_parameter("paint"))
		material.set_shader_parameter("sample_enabled76",true)
		material.set_shader_parameter("road_end_count77",meadow.road_endings77.size())
		material.set_shader_parameter("road_endings77",endings)
		material.set_shader_parameter("rail_line_z72",meadow.rail_z73)
		material.set_shader_parameter("rail_extent72",Vector2(meadow.rail_rect72.position.x,meadow.rail_rect72.end.x))
		if is_instance_valid(porch49): porch49.shade_material(material,shader)

func _title35() -> void:
	DisplayServer.window_set_title("小白鹅 · 地表恢复77 · 全图草土径 / 支路接续 / 手绘苔石墙")

func _ready() -> void:
	super._ready()
	while not is_instance_valid(wall76): await get_tree().physics_frame
	print("WORLD77_FULL_GROUND_CONNECTED_PATHS_AND_PAINTED_WALL_READY")
