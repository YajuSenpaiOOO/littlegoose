extends SceneTree
var checks := 0
var failures := 0
func _initialize() -> void: call_deferred("_run")
func verify(ok: bool,message: String) -> void:
	checks += 1
	if ok: print("PASS ",message)
	else:
		failures += 1
		push_error(message)

func _run() -> void:
	var scene: Node2D = load("res://scenes/sandbox/home_pixel_study.tscn").instantiate()
	root.add_child(scene)
	await physics_frame
	await physics_frame
	scene.hero.frozen = true
	verify(scene.standing_flowers.size()>25,"flower groups use independent upright plant instances")
	var sorted := true
	var passable := true
	var rooted := true
	var profiles := {}
	var authored_count := 0
	for child in scene.world.get_children():
		if child.name.begins_with("Flower"): authored_count += 1
	for flower in scene.standing_flowers:
		profiles[flower.profile.resource_path] = true
		sorted = sorted and flower.get_parent()==scene.world and flower.z_index==scene.hero.z_index and scene.world.y_sort_enabled and not flower.y_sort_enabled
		passable = passable and flower.get_node_or_null("Footprint")==null and flower.profile.footprint==Vector2.ZERO
		var bounds: Rect2i = flower.visual.texture.get_image().get_used_rect()
		var lowest: Vector2 = flower.visual.position+Vector2(0,bounds.end.y)*flower.visual.scale
		rooted = rooted and absf(lowest.y)<2.5 and flower.visual.position.y<0
	verify(sorted,"flowers and actors share Y sorting rather than a fixed ground layer")
	verify(passable,"all flowering plants are collider-free")
	verify(rooted,"upright textures meet their individual ground anchors")
	verify(profiles.size()==3 and authored_count==scene.standing_flowers.size(),"all three plant resources load and no incomplete flower instances remain")
	# Locate a physical corridor crossing a flower, then drive the real actor.
	var query := PhysicsShapeQueryParameters2D.new()
	var circle := CircleShape2D.new()
	circle.radius = 5
	query.shape = circle
	query.collision_mask = 1
	query.exclude = [scene.hero.get_rid(),scene.enemy.get_rid()]
	var target: Node2D
	for flower in scene.standing_flowers:
		var clear := true
		for dx in range(-18,26,2):
			query.transform = Transform2D(0,flower.position+Vector2(dx,-2))
			if not scene.get_world_2d().direct_space_state.intersect_shape(query).is_empty(): clear = false
		if clear:
			target = flower
			break
	verify(target!=null,"at least one flower group provides a clear traversal test corridor")
	if target:
		scene.hero.position = target.position+Vector2(-18,0)
		for i in 30:
			await physics_frame
			scene.hero.velocity = Vector2(78.3,0)
			scene.hero.move_and_slide()
		verify(scene.hero.position.x>target.position.x+14,"the real hero walks through a flower group without blocking")
	var key := InputEventKey.new()
	key.pressed = true
	key.physical_keycode = KEY_J
	scene._unhandled_key_input(key)
	verify(not scene.standing_flowers[0].visible,"J comparison toggles upright flower instances too")
	verify(scene.courtyard_ground.paving_material.get_shader_parameter("paving")==true and scene.courtyard_ground.ground_material.get_shader_parameter("material_atlas") is Texture2D,"paving and dirt sample the actual pixel material atlas")
	if "--render" in OS.get_cmdline_user_args(): await _capture_occlusion(scene)
	print("COURTYARD_FLOWER_PROBE ",checks-failures,"/",checks," passed")
	scene.queue_free()
	await process_frame
	quit(0 if failures==0 else 1)

func _capture_occlusion(scene: Node2D) -> void:
	scene.set_process(false)
	scene.label.hide()
	var plant: Node2D
	for flower in scene.standing_flowers:
		if flower.profile.resource_path.ends_with("flower_blue.tres"):
			plant = flower
			break
	if not plant: return
	for child in scene.world.get_children():
		if child is CanvasItem: child.visible = child==plant or child==scene.hero
	for prop in scene.registered_props: prop.local_projection.hide()
	for projection in scene.actor_projections: projection.hide()
	scene.solar_union.display.hide()
	scene.nature.hide()
	scene.camera.zoom = Vector2.ONE*8
	scene.camera.position = plant.position+Vector2(0,-13)
	scene.camera.force_update_scroll()
	for item in [[-3,"behind"],[3,"front"]]:
		scene.hero.position = plant.position+Vector2(0,item[0])
		scene.hero.visual.show()
		await process_frame
		await process_frame
		await RenderingServer.frame_post_draw
		var path: String = "res://docs/captures/flowers_%s_v2.png" % item[1]
		verify(root.get_texture().get_image().save_png(path)==OK,"saved real Y-sort occlusion capture: "+str(item[1]))
