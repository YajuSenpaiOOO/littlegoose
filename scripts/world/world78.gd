extends "res://scripts/world/world77.gd"
var scenery78: Node3D
var removed_trees78 := 0
var shifted_trees78 := 0

func _build_lab_floor() -> void:
	super._build_lab_floor()
	meadow=preload("res://scripts/world/world_surface78.gd").new()
func _time_script() -> Script: return preload("res://scripts/world/world_time78.gd")
func _bridge_script() -> Script: return preload("res://scripts/art/bridge_lake78.gd")

func _build_woodland() -> void:
	super._build_woodland()
	var rng := RandomNumberGenerator.new();rng.seed=780019
	var keep: Array[Dictionary]=[]
	for tree in trees:
		var at := Vector2(tree.root.position.x,tree.root.position.z)
		var forest := at.x< -20. and at.y< -20.
		var shore := at.x>22.
		if tree.root==landmark_tree.root or not (forest or shore): keep.append(tree);continue
		var groups := [Vector2(-72,-46),Vector2(-65,-70),Vector2(-48,-80),Vector2(-28,-68),Vector2(-23,-52),Vector2(-70,-26),Vector2(-41,-25),Vector2(-25,-32)] if forest else [Vector2(40,-54),Vector2(62,-49),Vector2(59,-15),Vector2(29,-9),Vector2(35,14),Vector2(55,-34)]
		var density := 0.
		for group in groups:
			var offset: Vector2=(at-group)/Vector2(8.,10.)
			density=maxf(density,exp(-offset.length_squared()*.5))
		if density<rng.randf_range(.22,.57):
			distant_roots.erase(tree.root);tree.root.free();removed_trees78+=1;continue
		var target := at+Vector2(rng.randf_range(-1.35,1.35),rng.randf_range(-1.35,1.35))
		if meadow.world_bounds.grow(-1.).has_point(target) and not meadow.is_water(target) and not meadow.is_open_ground(target) and meadow.route_distance(target)>2.2:
			at=target;tree.root.position=Vector3(at.x,meadow.height_at(at.x,at.y,true),at.y);shifted_trees78+=1
		var ratio := rng.randf_range(.84,1.20)
		tree.height*=ratio;tree.visual.pixel_size*=ratio
		keep.append(tree)
	trees.assign(keep)

func _assign_ground_materials() -> void:
	super._assign_ground_materials()
	var shader := preload("res://scripts/art/world_ground78.gdshader")
	for material in ground_materials:
		material.shader=shader
		material.set_shader_parameter("rock_paint78",preload("res://assets/garden45/slate.png"))
		if is_instance_valid(porch49): porch49.shade_material(material,shader)

func _ready() -> void:
	super._ready()
	while not is_instance_valid(wall76): await get_tree().physics_frame
	var bounds: Rect2=meadow.world_bounds
	water_material19.set_shader_parameter("shore59",load("res://assets/landscape78/shore_distance78.png"))
	water_material19.set_shader_parameter("bounds59",Vector4(bounds.position.x,bounds.position.y,bounds.size.x,bounds.size.y))
	scenery78=preload("res://scripts/art/landscape_edges78.gd").new();scenery78.world=self;add_child(scenery78)
	await get_tree().physics_frame
	navigation.bake(get_world_3d().direct_space_state,meadow,meadow.landmarks.grove)
	print("WORLD78_LAYERED_FOREST_AND_CURVED_SHORE_READY trees=",trees.size()," removed=",removed_trees78," shifted=",shifted_trees78)

func _title35() -> void:
	DisplayServer.window_set_title("小白鹅 · 林岸层次78 · 后林岩肩 / 曲岸 / 疏密树团")

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.physical_keycode==KEY_7 and not event.alt_pressed and not event.ctrl_pressed:
			set_review72(false);_teleport15(Vector2(-48.,-59.));return
		if event.physical_keycode==KEY_8 and event.ctrl_pressed:
			set_review72(false);_teleport15(meadow.landmarks.shore+Vector2(2.,-7.));return
	super._unhandled_input(event)
