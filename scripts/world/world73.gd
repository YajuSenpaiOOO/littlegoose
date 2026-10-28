extends "res://scripts/world/world72.gd"
var boundary_count73 := 0
var old_far73 := 160.

func floor_height(at: Vector2) -> float:
	if meadow.has_method("station_cap73") and meadow.station_cap73(at): return meadow.STATION_LEVEL73
	return super.floor_height(at)

func _build_lab_floor() -> void:
	super._build_lab_floor()
	meadow=preload("res://scripts/world/world_surface73.gd").new()
	var bounds: Rect2=meadow.world_bounds
	for child in get_children():
		if not child is MeshInstance3D or child.visible or not child.mesh is BoxMesh: continue
		if child.get_child_count()==0 or not child.get_child(0) is StaticBody3D: continue
		var size: Vector3=child.mesh.size
		if size.x<1.:
			child.position.x=bounds.position.x if child.position.x<bounds.get_center().x else bounds.end.x
			child.position.z=bounds.get_center().y;size.z=bounds.size.y
		else:
			child.position.z=bounds.position.y if child.position.z<bounds.get_center().y else bounds.end.y
			child.position.x=bounds.get_center().x;size.x=bounds.size.x
		child.mesh.size=size;child.get_child(0).get_child(0).shape.size=size;boundary_count73+=1

func _rail_script72() -> Script:
	return preload("res://scripts/art/rail_station73.gd")

func _time_script() -> Script:
	return preload("res://scripts/world/world_time73.gd")

func _assign_ground_materials() -> void:
	super._assign_ground_materials()
	for material in ground_materials:
		material.set_shader_parameter("rail_line_z72",meadow.rail_z73)
		material.set_shader_parameter("rail_extent72",Vector2(meadow.rail_rect72.position.x,meadow.rail_rect72.end.x))

func _grass_allowed19(at: Vector2) -> bool:
	if meadow.station_rect73.grow(.25).has_point(at): return false
	var start: Vector2=meadow.stair_start73()
	if absf(at.x-start.x)<2.8 and at.y>start.y-6.3 and at.y<start.y+.3: return false
	return super._grass_allowed19(at)

func _ready() -> void:
	super._ready()
	while not is_instance_valid(rail72): await get_tree().physics_frame
	await get_tree().physics_frame
	await get_tree().physics_frame
	# Existing station paving is retained geometrically and takes the same brick
	# surface as its raised base, rather than sitting on a grassy separate mound.
	for child in get_children():
		if child is MeshInstance3D and child.name=="DeparturePlaza": child.material_override=rail72.station_mesh73.material_override
	_title35();print("WORLD73_SPACED_REGIONS_AND_THROUGH_RAIL_READY")

func _process(delta: float) -> void:
	super._process(delta)
	if review72:
		var center: Vector2=meadow.world_bounds.get_center()
		camera.global_position=Vector3(center.x,2.5,center.y)+camera.global_basis.z*130.

func set_review72(value: bool) -> void:
	if value and not review72: old_far73=camera.far;camera.far=270.
	super.set_review72(value)
	if not value: camera.far=old_far73

func _title35() -> void:
	DisplayServer.window_set_title("小白鹅 · 林路与站台73 · 区域拉开 / 砖台基 / 贯通铁路")

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and not event.alt_pressed and not event.ctrl_pressed:
		if event.physical_keycode in [KEY_7,KEY_8]:
			set_review72(false)
			_teleport15(meadow.landmarks.grove+Vector2(16,8) if event.physical_keycode==KEY_7 else Vector2(meadow.landmarks.station.x,meadow.rail_z73+2.5));return
	super._unhandled_input(event)
