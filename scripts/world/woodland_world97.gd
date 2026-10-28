extends "res://scripts/world/woodland_world96.gd"
const PARK97=preload("res://scripts/world/park_layout97.gd")
var woodland_ready97 := false
var park97: Node3D
func _forest_script87() -> Script: return preload("res://scripts/art/forest_props97.gd")
func _rock_surfaces_script91() -> Script: return preload("res://scripts/art/rock_surfaces97.gd")
func _time_script() -> Script: return preload("res://scripts/world/woodland_time97.gd")
func _title35() -> void: DisplayServer.window_set_title("小白鹅 · 97 · 林间自然游园 / 高崖树林 / 秋千踏桩")
func _build_lab_floor() -> void:
	super._build_lab_floor();meadow=preload("res://scripts/world/world_surface97.gd").new()
func _build_woodland() -> void:
	super._build_woodland()
	var g: Vector2=meadow.landmarks.grove
	for tree in trees:
		var p: Vector2=Vector2(tree.root.position.x,tree.root.position.z)-g
		var target := p
		if tree.root.has_meta("finger93"):
			if p.distance_to(Vector2(-8,-2))<.2: target=Vector2(-5.95,-6.375)
			elif p.distance_to(Vector2(-12,1))<.2: target=Vector2(-15.2,3.5)
			elif p.distance_to(Vector2(8,-9))<.2: target=Vector2(11.5,-12.5)
		if target!=p: tree.root.position=Vector3(g.x+target.x,meadow.height_at(g.x+target.x,g.y+target.y,true),g.y+target.y)
	for offset in [Vector2(-25,-24),Vector2(-25,-15),Vector2(-26,-6),Vector2(-25,3),Vector2(-26,11),Vector2(-22,-29),Vector2(-16,-8.5),Vector2(-4.8,-5.2),Vector2(11.55,-6.6)]:
		var at: Vector2=g+offset
		var near := false
		for tree in trees:
			if Vector2(tree.root.position.x,tree.root.position.z).distance_to(at)<2.: near=true;break
		if not near and meadow.normal_at(at.x,at.y,true).y>.95: _add_route_tree(at,8.3 if offset.x< -20. else 7.8)
func _grass_growth92(at: Vector2) -> float:
	var growth := super._grass_growth92(at)
	var p: Vector2=at-Vector2(meadow.landmarks.grove)
	if PARK97.on_stairs97(p): return 0.
	return lerpf(growth,.04,1.-smoothstep(.75,1.5,PARK97.path_distance97(p)))
func _refresh_planting() -> void:
	super._refresh_planting()
	var g: Vector2=meadow.landmarks.grove
	for item in grass_poses92:
		var point: Vector3=item.node.to_global(item.after.origin)
		var p := Vector2(point.x,point.z)-g
		if PARK97.path_distance97(p)<.94 or PARK97.on_stairs97(p) or (p-PARK97.DECK).length()<2.9:
			item.after.basis=Basis(Vector3.ZERO,Vector3.ZERO,Vector3.ZERO)
			item.before.basis=Basis(Vector3.ZERO,Vector3.ZERO,Vector3.ZERO)
			item.node.multimesh.set_instance_transform(item.index,item.after)
func _ready() -> void:
	super._ready()
	while not woodland_ready96: await get_tree().physics_frame
	park97=preload("res://scripts/art/nature_park97.gd").new();park97.world=self;add_child(park97)
	await get_tree().physics_frame
	navigation.bake(get_world_3d().direct_space_state,meadow,meadow.landmarks.grove)
	woodland_ready97=true;_title35();time55.update_guide()
	print("WOODLAND97_READY")
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and event.ctrl_pressed and event.alt_pressed:
		if event.physical_keycode==KEY_F2: set_review72(false);_teleport15(meadow.landmarks.grove+Vector2(-1,5));return
		if event.physical_keycode==KEY_F3: set_review72(false);_teleport15(meadow.landmarks.grove+Vector2(8,-2));return
	super._unhandled_input(event)
