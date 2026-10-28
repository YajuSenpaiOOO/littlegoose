extends SceneTree
var failures: Array[String] = []
var checks := 0
func _initialize() -> void: run.call_deferred()
func verify(ok: bool,message: String) -> void:
	checks += 1
	if not ok: failures.append(message)
	print("PASS " if ok else "FAIL ",message)
func run() -> void:
	var sample: Node2D = load("res://scenes/sandbox/view25_playground.tscn").instantiate()
	root.add_child(sample)
	await process_frame
	sample.set_process(false)
	verify(sample.angles[sample.angle_index]==25.0,"specimen uses 25 degree geometry")
	var roundtrip := true
	for at in [Vector2(-550,-500),Vector2.ZERO,Vector2(520,530)]:
		for h in [0.0,35.0,190.0]:
			roundtrip = roundtrip and sample.unproject(sample.p(at,h),h).distance_to(at)<0.001
	verify(roundtrip,"cursor inverse matches ground and lifted drawing positions")
	verify(sample.field.tufts.size()==720 and sample.world.y_sort_enabled,"720 passable grass tufts share foot sorting with actors")
	var grass_clear := true
	for tuft in sample.field.tufts:
		grass_clear = grass_clear and sample._grass_allowed(tuft.position) and tuft.get_child_count()==0
	verify(grass_clear,"grass avoids solid footprints and has no per-tuft physics")
	# Actual swept projectile simulation, including steep screen directions.
	sample.ground_position = Vector2(-230,380)
	var before: int = sample.hits
	for i in 8:
		sample.target_ground = sample.ground_position+Vector2.from_angle(TAU*i/8.0)*140
		sample.fire_at(sample.p(sample.target_ground,sample.SHOT_HEIGHT))
		for j in 60: sample.step_shots(1.0/60.0)
	verify(sample.hits-before==8,"mouse-to-body aiming hits from all eight directions")
	before = sample.hits
	sample.ground_position = Vector2(0,100)
	sample.target_ground = Vector2(0,-500)
	var blocked: int = sample.blocked_shots
	sample.fire_at(sample.p(sample.target_ground,sample.SHOT_HEIGHT))
	for j in 3: sample.step_shots(0.6)
	verify(sample.hits==before and sample.blocked_shots==blocked+1,"large projectile steps cannot tunnel through house to target")
	sample.ground_position = Vector2(-443,200)
	sample.target_ground = Vector2(-443,-160)
	blocked = sample.blocked_shots
	sample.fire_at(sample.p(sample.target_ground,sample.SHOT_HEIGHT))
	for j in 40: sample.step_shots(1.0/60.0)
	verify(sample.blocked_shots==blocked+1,"tree blocks at trunk footprint rather than canopy")
	# Probe visually covered but legally walkable ground behind the house.
	sample.hero.position = sample.p(Vector2(0,-400))
	sample._update_fading(1.0)
	verify(sample.bodies[0].node.modulate.a<0.3,"house fades when it obscures the character behind it")
	sample.hero.position = sample.p(Vector2(0,190))
	sample._update_fading(1.0)
	verify(is_equal_approx(sample.bodies[0].node.modulate.a,1.0),"house restores opacity after the character returns")
	# Feed actual movement input through the same loop used by the specimen.
	sample.ground_position = Vector2(0,-80)
	var key := InputEventKey.new()
	key.physical_keycode = KEY_W
	key.pressed = true
	Input.parse_input_event(key.duplicate())
	await process_frame
	for j in 60: sample._process(1.0/60.0)
	key.pressed = false
	Input.parse_input_event(key.duplicate())
	verify(sample.ground_position.y>=-114 and sample.ground_position.y < -80,"walking stops at the house footprint")
	# Walk in the actual update loop while following at a non-default zoom.
	sample.ground_position = Vector2(-230,380)
	sample.hero.position = sample.p(sample.ground_position)
	sample.zoom_value = 1.4
	sample.camera.zoom = Vector2.ONE*1.4
	sample._follow_camera(0,true)
	var camera_start: Vector2 = sample.camera.position
	key.physical_keycode = KEY_D
	key.pressed = true
	Input.parse_input_event(key.duplicate())
	await process_frame
	for j in 30: sample._process(1.0/60.0)
	key.pressed = false
	Input.parse_input_event(key.duplicate())
	var lead: Vector2 = sample.hero.position+Vector2(0,-110)/sample.zoom_value
	verify(sample.camera.position.x>camera_start.x+60 and sample.camera.position.distance_to(lead)<28 and sample.camera.zoom==Vector2.ONE*1.4,"camera follows real walking while retaining wheel zoom")
	key.physical_keycode = KEY_C
	key.pressed = true
	sample._unhandled_key_input(key)
	camera_start = sample.camera.position
	sample.hero.position += Vector2(80,0)
	sample._follow_camera(0.5)
	verify(not sample.follow_camera and sample.camera.position==camera_start,"C freezes camera for direct comparison")
	sample._unhandled_key_input(key)
	sample._follow_camera(0.5)
	verify(sample.follow_camera and sample.camera.position.x>camera_start.x,"C restores following")
	# Camera transforms are inverted before the sample's ground unprojection.
	sample.camera.zoom = Vector2.ONE*1.7
	sample.camera.force_update_scroll()
	var aim: Vector2 = sample.p(Vector2(340,200),sample.SHOT_HEIGHT)
	var canvas: Transform2D = sample.get_canvas_transform()
	verify((canvas.affine_inverse()*(canvas*aim)).distance_to(aim)<0.001,"zoom preserves cursor world coordinates for aiming")
	print(JSON.stringify({"checks":checks,"failures":failures}))
	quit(0 if failures.is_empty() else 1)

