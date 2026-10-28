extends "res://scripts/ground_lab_probe.gd"

func drive(keys: Array) -> void:
	for key in [KEY_W,KEY_A,KEY_S,KEY_D]:
		var input := event(key)
		input.pressed = key in keys
		Input.parse_input_event(input)

func run() -> void:
	var sample: Node3D = load("res://scenes/sandbox/yard_route15.tscn").instantiate()
	root.add_child(sample)
	sample.hero.controls_enabled = false
	for i in 15: await physics_frame
	verify(sample.art_style==1 and sample.hero.is_on_floor(),"selected style2 remains fixed and actual actor lands on extended terrain")
	verify(sample.extra_textures.size()==8 and sample.props15.size()==4,"two cottage candidates, three tree shapes and three prop types are integrated")
	verify(sample.meadow.main_route.size()==8 and sample.meadow.route.size()>8 and sample.meadow.route[-1].y< -24.,"original home_to_junction topology is mapped into a smoothed continuous route")
	verify(sample.grass.multimesh.instance_count==5600 and sample.mixed_grass,"short/tall grass extends along the route in one reactive batch")
	var cleared := true
	for transform in sample.planting:
		cleared = cleared and sample.meadow.route_distance(Vector2(transform.origin.x,transform.origin.z))>=1.04
	verify(cleared,"grass does not occupy the new walking corridor")
	var root_error := 0.
	var skirt_count := 0
	for piece in sample.root_pieces:
		var mesh: ArrayMesh = piece.node.mesh
		var arrays := mesh.surface_get_arrays(0)
		var vertices: PackedVector3Array = arrays[Mesh.ARRAY_VERTEX]
		for i in range(0,vertices.size(),37):
			var p: Vector3 = piece.node.to_global(vertices[i])
			root_error = maxf(root_error,absf(p.y-sample.meadow.height_at(p.x,p.z,true)-.012))
		skirt_count += 1
	verify(root_error<.0001 and skirt_count==sample.trees.size()+4,"every tree root and prop-foot band is seated on actual terrain coordinates")
	verify(sample.shadow_volume.get_child_count()==2 and sample.house_art.cast_shadow==GeometryInstance3D.SHADOW_CASTING_SETTING_OFF and sample.foundation.visible,"calibrated house uses a gabled volume shadow and a narrow seated plinth")
	var camera_at: Vector3 = sample.camera.position
	var root_at: Vector3 = sample.cottage_root.position
	var body_id: RID = sample.cottage_body.get_rid()
	var images: Array[Texture2D] = []
	var stable := true
	for variant in 3:
		sample._set_house_variant(variant)
		images.append(sample.house_art.texture)
		stable = stable and sample.camera.position==camera_at and sample.cottage_root.position==root_at and sample.cottage_body.get_rid()==body_id
	verify(stable and images[0]!=images[1] and images[1]!=images[2],"three house choices change art without moving the camera root or physical footprint")
	sample._set_house_variant(1)
	sample._unhandled_input(event(KEY_P))
	var hidden := true
	for prop in sample.props15: hidden = hidden and not prop.root.visible and prop.body.collision_layer==0
	sample._unhandled_input(event(KEY_P))
	verify(hidden and sample.props15[0].root.visible and sample.props15[0].body.collision_layer==2,"prop comparison removes and restores both pictures and collision")
	# Actual movement toward the seated trunk, then toward the cottage doorway.
	var trunk_tree: Dictionary = sample.trees[85]
	var trunk := Vector3.ZERO
	for child in trunk_tree.root.get_children():
		if child is StaticBody3D: trunk = child.get_child(0).global_position
	sample._teleport15(Vector2(trunk.x+2.,trunk.z))
	for i in 8: await physics_frame
	sample.hero.controls_enabled = true
	drive([KEY_A])
	for i in 40: await physics_frame
	drive([])
	sample.hero.controls_enabled = false
	for i in 6: await physics_frame
	verify(sample.hero.position.x>trunk.x+.45 and sample.hero.position.x<trunk.x+1.1 and sample.hero.is_on_floor(),"actual actor stops against the calibrated visible trunk rather than its root toe")
	sample._teleport15(Vector2(-4.7,-3.4))
	for i in 8: await physics_frame
	sample.hero.controls_enabled = true
	drive([KEY_W])
	for i in 40: await physics_frame
	drive([])
	sample.hero.controls_enabled = false
	for i in 6: await physics_frame
	verify(sample.hero.position.z> -5.2 and sample.hero.position.z< -4.5 and sample.hero.is_on_floor(),"calibrated house footprint blocks the actor at the front doorstep")
	# Walk from the doorstep out to the mapped junction using real movement input.
	sample._teleport15(Vector2(-4.7,-3.6))
	for i in 10: await physics_frame
	sample.hero.controls_enabled = true
	var target := 1
	var fallen := false
	var steps := 0
	for step in 1000:
		steps += 1
		var at := Vector2(sample.hero.position.x,sample.hero.position.z)
		var goal: Vector2 = sample.meadow.main_route[target]
		var delta := goal-at
		if delta.length()<.45:
			target += 1
			if target>=sample.meadow.main_route.size(): break
			goal = sample.meadow.main_route[target]
			delta = goal-at
		var direction := delta.normalized()
		var keys: Array = []
		if direction.x> .32: keys.append(KEY_D)
		if direction.x< -.32: keys.append(KEY_A)
		if direction.y> .32: keys.append(KEY_S)
		if direction.y< -.32: keys.append(KEY_W)
		drive(keys)
		await physics_frame
		fallen = fallen or sample.hero.position.y< -2.
	drive([])
	sample.hero.controls_enabled = false
	for i in 8: await physics_frame
	verify(target>=sample.meadow.main_route.size() and not fallen and sample.hero.is_on_floor(),"actual player input traverses the complete cottage-to-forest route beyond the old z=-15 boundary")
	# Freeze the scene and compare actual contact/projection rendering.
	sample._teleport15(Vector2(0,3))
	for i in 8: await physics_frame
	sample.set_process(false)
	sample.set_physics_process(false)
	sample.hero.set_physics_process(false)
	sample.camera.physics_interpolation_mode = Node.PHYSICS_INTERPOLATION_MODE_OFF
	sample.camera.reset_physics_interpolation()
	sample.label.get_parent().hide()
	sample.wind_enabled = false
	sample.set_candidate(3)
	sample.set_contact(true)
	var seated := await snapshot()
	sample.shadow_volume.hide()
	var no_volume := await snapshot()
	sample.shadow_volume.show()
	var volume_restored := await snapshot()
	var whole := Rect2i(Vector2i.ZERO,seated.get_size())
	verify(changed(seated,no_volume,whole)>100,"gabled building volume casts a measurable actual rendered shadow")
	verify(changed(seated,volume_restored,whole)==0,"building shadow returns to the same frozen frame")
	sample.set_contact(false)
	var old := await snapshot()
	var baseline_ok: bool = sample.root_pieces[0].sprite.position.y==0 and not sample.root_pieces[0].node.visible and not sample.shadow_volume.visible and sample.house_art.cast_shadow==GeometryInstance3D.SHADOW_CASTING_SETTING_ON
	sample.set_contact(true)
	var restored := await snapshot()
	var area := Rect2i(Vector2i.ZERO,seated.get_size())
	var changed_pixels := changed(seated,old,area)
	verify(baseline_ok and changed_pixels>1000,"V restores original floating-card geometry and changes the rendered root/foundation/shadow result")
	verify(changed(seated,restored,area)==0,"contact calibration restores a pixel-identical frozen view")
	sample._unhandled_input(event(KEY_T))
	for i in 3: await physics_frame
	var flat_ok := true
	for tree in sample.trees: flat_ok = flat_ok and absf(tree.root.position.y)<.0001
	for prop in sample.props15: flat_ok = flat_ok and absf(prop.root.position.y)<.0001
	verify(flat_ok,"terrain toggle reseats extended forest, props and root skirts together")
	print("YARD15 route_steps=",steps," target=",target," skirts=",skirt_count," root_error=",root_error," contact_pixels=",changed_pixels)
	print(JSON.stringify({"checks":checks,"failures":failures}))
	quit(0 if failures.is_empty() else 1)
