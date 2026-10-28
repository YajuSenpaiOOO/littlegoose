extends "res://scripts/ground_lab_probe.gd"
func run() -> void:
	var sample: Node3D = load("res://scenes/world/world22.tscn").instantiate()
	root.add_child(sample)
	while not sample.combat_ready or not is_instance_valid(sample.feedback): await physics_frame
	sample.start_combat()
	sample.hero.controls_enabled = false
	for enemy in sample.enemies: enemy.set_physics_process(false)
	var center: Vector2 = sample.meadow.landmarks.grove
	var victim: CharacterBody3D = sample.enemies[0]
	victim.position = Vector3(center.x,sample.meadow.walk_height(center,true)+.04,center.y)
	victim.reset_physics_interpolation()
	for i in 5: await physics_frame
	var worst := 0.
	sample.gentle_assist = false
	for distance in [12.,18.,28.]:
		sample.camera_distance = distance
		sample._update_camera(0,true)
		for offset in [Vector2(-3,1),Vector2(4,-2),Vector2(-5,-5)]:
			var at: Vector2 = center+offset
			var cursor: Vector2 = sample.camera.unproject_position(Vector3(at.x,sample.meadow.walk_height(at,true),at.y))
			var aim: Vector3 = sample.aim_at_screen(cursor)
			var error: float = sample.camera.unproject_position(aim).distance_to(cursor)
			worst = maxf(worst,error)
			verify(aim.is_finite() and error<.02,"free aim projects back to cursor at zoom %.0f / %s"%[distance,offset])
	sample.camera_distance = 15.
	sample._update_camera(0,true)
	sample.gentle_assist = true
	for pose in ["idle","anticipation","airborne","landing","hit","defeated"]:
		victim.hp = 12.
		victim.flash = 0.
		var lift := .38 if pose=="airborne" else 0.
		victim._pose(pose,lift)
		var body: Vector3 = victim.visual.global_position+Vector3.UP*float(sample.combat_poses[pose].visible_height)/24.*.5
		var cursor: Vector2 = sample.camera.unproject_position(body)
		verify(sample.enemy_under_cursor(cursor)==victim,"visible sprite pixels select the enemy: "+pose)
		var aim: Vector3 = sample.aim_at_screen(cursor)
		verify(Vector2(aim.x,aim.z).distance_to(Vector2(victim.position.x,victim.position.z))<.1,"light assistance points to gameplay body independent of pose: "+pose)
		sample.fire_at(aim)
		for i in 18: await physics_frame
		verify(victim.hp==8.,"planar swept hit connects independent of hop pose: "+pose)
	verify(sample.feedback_count==6 and sample.landed_hits==6,"every physical hit emits feedback exactly once")
	verify(sample.aim_model.sweep_circle(Vector2(0,-5),Vector2(0,5),Vector2.ZERO,.65)<1.,"swept circle cannot tunnel across the body in a long frame")
	var fired: int = sample.fired_count
	sample.fire_at(sample.hero.position+Vector3.UP*.85)
	verify(sample.fired_count==fired,"aiming exactly at muzzle does not create an invalid shot")
	sample._unhandled_input(event(KEY_F8))
	verify(not sample.planar_aim and sample.shots.is_empty(),"F8 switches to original aiming and clears old projectiles")
	sample._unhandled_input(event(KEY_F8))
	sample._unhandled_input(event(KEY_F9))
	verify(sample.planar_aim and not sample.gentle_assist,"F9 offers planar free aim without assistance")
	FileAccess.open("res://docs/aim22-validation.json",FileAccess.WRITE).store_string(JSON.stringify({"checks":checks,"failures":failures,"max_cursor_error_px":worst},"\t"))
	print("AIM22_PROBE ",checks," checks; failures=",failures.size()," cursor_error=",worst)
	quit(0 if failures.is_empty() else 1)
