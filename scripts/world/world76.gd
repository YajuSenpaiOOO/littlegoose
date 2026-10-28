extends "res://scripts/world/world75.gd"
var wall76: Node3D
var art_sample76 := true

func _roadside_wall_script76() -> Script: return preload("res://scripts/art/roadside_wall76.gd")

func _build_lab_floor() -> void:
	super._build_lab_floor()
	meadow=preload("res://scripts/world/world_surface76.gd").new()
func _whole_fade_script67() -> Script: return preload("res://scripts/art/whole_tree_fade76.gd")
func _navigation_script72() -> Script: return preload("res://scripts/combat/woodland_navigation76.gd")
func _time_script() -> Script: return preload("res://scripts/world/world_time76.gd")
func _enemy_script() -> Script:
	return preload("res://scripts/combat/tuantuan76.gd") if legacy_feel else super._enemy_script()
func _encounter_leave_radius37() -> float: return 29.
func _wave_return_radius40() -> float: return 27.

func _assign_ground_materials() -> void:
	super._assign_ground_materials()
	var shader := preload("res://scripts/art/world_ground76.gdshader")
	for material in ground_materials:
		material.shader=shader
		material.set_shader_parameter("paint",ground_templates[3].get_shader_parameter("paint"))
		material.set_shader_parameter("rail_line_z72",meadow.rail_z73)
		material.set_shader_parameter("rail_extent72",Vector2(meadow.rail_rect72.position.x,meadow.rail_rect72.end.x))
		material.set_shader_parameter("sample_enabled76",art_sample76)
		if is_instance_valid(porch49): porch49.shade_material(material,shader)

func set_art_sample76(value: bool) -> void:
	art_sample76=value
	for material in ground_materials: material.set_shader_parameter("sample_enabled76",value)
	if is_instance_valid(wall76): wall76.wall_mesh76.visible=value

func _ready() -> void:
	super._ready()
	while not is_instance_valid(rail72) or not is_instance_valid(frames66): await get_tree().physics_frame
	await get_tree().physics_frame
	await get_tree().physics_frame
	wall76=_roadside_wall_script76().new();wall76.world=self;add_child(wall76)
	await get_tree().physics_frame
	navigation.bake(get_world_3d().direct_space_state,meadow,meadow.landmarks.grove)
	print("WORLD76_CAMERA_SAFE_WOODLAND_AND_ART_SAMPLE_READY")

func _title35() -> void:
	DisplayServer.window_set_title("小白鹅 · 林地样板76 · 近镜头保护 / 大战场 / 草土径与厚墙")

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and not event.alt_pressed and not event.ctrl_pressed and event.physical_keycode==KEY_7:
		set_review72(false);_teleport15(Vector2(-26.,-32.3));return
	super._unhandled_input(event)
