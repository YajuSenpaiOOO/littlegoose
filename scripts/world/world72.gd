extends "res://scripts/world/world68.gd"
var rail72: Node3D
var review72 := false
var review_anchor72 := Vector3.ZERO
var review_nodes72: Array[Dictionary]=[]
var review_atmosphere72 := true
var review_fog72 := true

func _build_lab_floor() -> void:
	meadow=preload("res://scripts/world/world_surface72.gd").new()
	# Same continuous-world floor, with the expanded bounds applied BEFORE
	# building boundary bodies. Earlier versions keep their original boundaries.
	ground=MeshInstance3D.new()
	var plane := PlaneMesh.new(); plane.size=Vector2(200,200); ground.mesh=plane
	add_child(ground)
	var body := StaticBody3D.new(); body.collision_layer=1
	floor_collider=CollisionShape3D.new(); floor_collider.shape=plane.create_trimesh_shape()
	body.add_child(floor_collider); ground.add_child(body)
	var bounds: Rect2=meadow.world_bounds
	for x in [bounds.position.x,bounds.end.x]: _box(Vector3(x,5,bounds.get_center().y),Vector3(.3,16,bounds.size.y),Color.TRANSPARENT,true,false)
	for z in [bounds.position.y,bounds.end.y]: _box(Vector3(bounds.get_center().x,5,z),Vector3(bounds.size.x,16,.3),Color.TRANSPARENT,true,false)

func _grass_allowed19(at: Vector2) -> bool:
	return not meadow.rail_rect72.grow(.5).has_point(at) and meadow.normal_at(at.x,at.y,true).y>.88

func _assign_ground_materials() -> void:
	super._assign_ground_materials()
	for material in ground_materials:
		material.shader=preload("res://scripts/art/terrain_blockout72.gdshader")
		if is_instance_valid(porch49): porch49.shade_material(material)

func _lamp_shadow_script() -> Script:
	return preload("res://scripts/art/local_lamp_shadow69.gd")

func _time_script() -> Script:
	return preload("res://scripts/world/world_time72.gd")

func _rail_script72() -> Script:
	return preload("res://scripts/art/rail_corridor72.gd")

func _navigation_script72() -> Script:
	return preload("res://scripts/combat/woodland_navigation72.gd")

func _build_map_panel() -> void:
	map_panel=preload("res://scripts/world/world_map72.gd").new()
	map_panel.surface=meadow; map_panel.actor=hero
	map_panel.z_index=100
	map_panel.position=Vector2(1165,20); map_panel.size=Vector2(410,322)
	label.get_parent().add_child(map_panel); map_panel.hide()

func _ready() -> void:
	super._ready()
	while not is_instance_valid(local68): await get_tree().physics_frame
	rail72=_rail_script72().new(); rail72.world=self; add_child(rail72)
	navigation=_navigation_script72().new()
	await get_tree().physics_frame
	navigation.bake(get_world_3d().direct_space_state,meadow,meadow.landmarks.grove)
	if not "--combat" in OS.get_cmdline_user_args():
		_teleport15(meadow.landmarks.junction+Vector2(-12,-1))
		time55.preview_at(12.); time55.visual_hour=12.; time55.apply_look()
	time55.update_guide(); _title35()
	print("WORLD72_CONNECTED_TERRAIN_AND_RAIL_READY")

func _process(delta: float) -> void:
	super._process(delta)
	if not review72: return
	if hero.global_position.distance_to(review_anchor72)>.25:
		set_review72(false); return
	var center: Vector2=meadow.world_bounds.get_center()
	camera.global_position=Vector3(center.x,2.5,center.y)+camera.global_basis.z*114.

func set_review72(value: bool) -> void:
	if value==review72: return
	review72=value
	if value:
		review_anchor72=hero.global_position
		review_atmosphere72=atmosphere41.enabled
		review_fog72=atmosphere41.environment.fog_enabled
		atmosphere41.enabled=false; atmosphere41.environment.fog_enabled=false
		review_nodes72.clear()
		for tree in trees:
			review_nodes72.append({"node":tree.visual,"end":tree.visual.visibility_range_end})
			if tree.has("shadow19"): review_nodes72.append({"node":tree.shadow19,"end":tree.shadow19.visibility_range_end})
		for piece in root_pieces: review_nodes72.append({"node":piece.node,"end":piece.node.visibility_range_end})
		for item in review_nodes72: item.node.visibility_range_end=0.
	else:
		atmosphere41.enabled=review_atmosphere72; atmosphere41.environment.fog_enabled=review_fog72
		for item in review_nodes72:
			if is_instance_valid(item.node): item.node.visibility_range_end=item.end
		review_nodes72.clear()

func _title35() -> void:
	DisplayServer.window_set_title("小白鹅 · 整体地形72 · 主台地 / 后林台 / 北侧铁路（结构稿）")

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and not event.alt_pressed and not event.ctrl_pressed:
		if event.physical_keycode==KEY_9:
			set_review72(not review72); return
		if event.physical_keycode in [KEY_7,KEY_8]:
			set_review72(false)
			_teleport15(Vector2(-25,-31) if event.physical_keycode==KEY_7 else Vector2(4,-59.0)); return
	super._unhandled_input(event)
