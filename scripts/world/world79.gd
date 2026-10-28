extends "res://scripts/world/world78.gd"
var accents79: Node3D
var far_tree_count79 := 0
var review_far79 := 270.

func _build_lab_floor() -> void:
	super._build_lab_floor()
	meadow=preload("res://scripts/world/world_surface79.gd").new()
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
		child.mesh.size=size;child.get_child(0).get_child(0).shape.size=size

func _time_script() -> Script: return preload("res://scripts/world/world_time79.gd")
func _rail_script72() -> Script: return preload("res://scripts/art/rail_station79.gd")
func _water_pieces19() -> Array[PackedVector2Array]: return meadow.lake_pieces79()
func _earth_clears_grass79() -> bool: return true

func _grass_allowed19(at: Vector2) -> bool:
	var patch: Vector2=meadow.ground_cover79(at)
	if _earth_clears_grass79() and patch.x<1.5 and patch.y>.62: return false
	return super._grass_allowed19(at)

func _build_woodland() -> void:
	super._build_woodland()
	var rng := RandomNumberGenerator.new();rng.seed=790079
	# Dense groups on the opposite bank close the lake view. Their silhouettes
	# remain real trees, using the same fade/grounding path as nearby woodland.
	for z in range(-79,13,4):
		for x in range(39,122,4):
			var at := Vector2(x+rng.randf_range(-1.,1.),z+rng.randf_range(-1.,1.))
			var far_east := at.x>104.
			var far_north := at.y< -63. and at.x>44.
			if not (far_east or far_north) or rng.randf()<.19: continue
			if meadow.is_water(at) or meadow.shore_distance78(at)<4.5 or meadow.rail_rect72.grow(3.).has_point(at) or meadow.station_rect73.grow(3.).has_point(at): continue
			if meadow.normal_at(at.x,at.y,true).y<.88: continue
			_add_route_tree(at,rng.randf_range(7.2,10.5))
			trees[-1].root.name="FarLakeForest79_%03d"%far_tree_count79
			trees[-1].visual.modulate=Color(.76,.86,.84)
			far_tree_count79+=1

func _assign_ground_materials() -> void:
	super._assign_ground_materials()
	var shader := preload("res://scripts/art/world_ground79.gdshader")
	var areas := PackedVector4Array();var kinds := PackedFloat32Array()
	for patch in meadow.ground_patches79: areas.append(patch.area);kinds.append(patch.kind)
	for material in ground_materials:
		material.shader=shader
		material.set_shader_parameter("ground_patches79",areas)
		material.set_shader_parameter("patch_kinds79",kinds)
		if is_instance_valid(porch49): porch49.shade_material(material,shader)

func _ready() -> void:
	super._ready()
	while not is_instance_valid(scenery78): await get_tree().physics_frame
	water_material19.set_shader_parameter("shore59",load("res://assets/landscape79/shore_distance79.png"))
	accents79=preload("res://scripts/art/ground_accents79.gd").new();accents79.world=self;add_child(accents79)
	print("WORLD79_COTTAGE_GROUND_VARIETY_AND_ENCLOSED_LAKE_READY far_trees=",far_tree_count79)

func set_review72(value: bool) -> void:
	if value and not review72: review_far79=camera.far
	super.set_review72(value)
	if value: camera.far=380.
	else: camera.far=review_far79

func _process(delta: float) -> void:
	super._process(delta)
	if review72:
		var center: Vector2=meadow.world_bounds.get_center()
		camera.global_position=Vector3(center.x,2.5,center.y)+camera.global_basis.z*176.

func _title35() -> void:
	DisplayServer.window_set_title("小白鹅 · 湖院79 · 门阶接路 / 泥土花地 / 扩湖远岸")
