extends "res://scripts/ground_lab_probe.gd"
func run() -> void:
	var sample: Node3D = load("res://scenes/world/world28.tscn").instantiate()
	root.add_child(sample)
	while not is_instance_valid(sample.reticle) or sample.reticle.get_script()!=preload("res://scripts/combat/muzzle_reticle28.gd"): await physics_frame
	sample.start_combat()
	sample.hero.controls_enabled=false
	for enemy in sample.enemies: enemy.set_physics_process(false)
	for i in 4: await physics_frame
	var screen_origin: Vector2 = sample.camera.unproject_position(sample.projectile_origin())
	var velocities := []
	for i in 8:
		var pixel := screen_origin+Vector2(cos(i*PI/4.),sin(i*PI/4.))*180.
		var target: Vector3 = sample.aim_at_screen(pixel)
		var origin: Vector3 = sample.projectile_origin()
		sample.fire_at(target)
		var shot: Dictionary = sample.shots[-1]
		var expected := origin.direction_to(target)
		verify(shot.velocity.normalized().dot(expected)>.999999,"precise shot matches muzzle-to-cursor ray at octant "+str(i))
		var projected: Vector2 = sample.camera.unproject_position(origin+shot.velocity*.01)-sample.camera.unproject_position(origin)
		var wanted: Vector2 = sample.camera.unproject_position(target)-sample.camera.unproject_position(origin)
		verify(projected.normalized().dot(wanted.normalized())>.99999,"screen trajectory points to cursor including diagonals "+str(i))
		velocities.append(projected.length()*100.)
		sample._clear_combat_shots()
	verify(sample.weapon_spread_radians()==0.,"precision comparison starts without random spread")
	var victim: CharacterBody3D=sample.enemies[0]
	var center: Vector2=sample.meadow.landmarks.grove
	victim.position=Vector3(center.x,sample.floor_height(center)+.04,center.y+1.)
	victim._pose("idle",0.)
	for i in 3: await physics_frame
	var body_pixel: Vector2=sample.camera.unproject_position(victim.visual.global_position+Vector3.UP*.6)
	var hp: float=victim.hp
	sample.fire_at(sample.aim_at_screen(body_pixel))
	for i in 90:
		await physics_frame
		if sample.landed_hits>0: break
	verify(victim.hp==hp-1.,"precision mode still hits through real native 3D collision")
	sample._clear_combat_shots()
	sample._unhandled_input(event(KEY_Z))
	verify(is_equal_approx(sample.weapon_spread_radians(),.025),"Z restores exact legacy spread")
	sample._unhandled_input(event(KEY_Z))
	var target: Vector3 = sample.hero.position+Vector3(3,.85,-4)
	sample.reticle.update_target(target)
	verify(sample.reticle.line_origin.distance_to(sample.preview_projectile_origin())<.00001,"guide starts at the visible goose muzzle")
	var before: Vector3 = sample.reticle.line_origin
	sample.goose.position += Vector3(2,0,-1)
	sample.goose.reset_physics_interpolation()
	sample.goose.visual.reset_physics_interpolation()
	sample.reticle.update_target(target)
	verify(sample.reticle.line_origin.distance_to(before)>1.5,"guide follows a detached goose rather than staying with hero")
	var physical_origin: Vector3 = sample.projectile_origin()
	# Put a real blocking wall across the trajectory; the line must stop there.
	var wall := StaticBody3D.new()
	wall.collision_layer=2
	var collider := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size=Vector3(.8,3,.8)
	collider.shape=box
	wall.add_child(collider)
	sample.add_child(wall)
	wall.global_position=physical_origin.lerp(target,.5)
	await physics_frame
	sample.reticle.update_target(target)
	verify(not sample.reticle.path_hit.is_empty() and sample.reticle.path_hit.collider==wall,"actual wall clips the muzzle guide")
	verify(sample.reticle.guide_ink.albedo_color.r>sample.reticle.guide_ink.albedo_color.g,"blocked trajectory turns orange")
	wall.queue_free()
	sample._unhandled_input(event(KEY_E))
	sample.reticle.update_target(target)
	verify(sample.reticle.ground_ring.visible and not sample.reticle.guide_mesh.visible,"E restores old ground-indicator comparison")
	sample._unhandled_input(event(KEY_E))
	sample.reticle.update_target(target)
	verify(not sample.reticle.ground_ring.visible and not sample.reticle.guide_mesh.visible,"E can hide both auxiliary aids")
	sample._unhandled_input(event(KEY_E))
	# Clean GPU illustration aiming at a real enemy, and prove the guide renders.
	var pixel: Vector2=sample.camera.unproject_position(victim.position+Vector3.UP*.7)
	Input.warp_mouse(pixel*Vector2(root.size)/root.get_visible_rect().size)
	for i in 30: await physics_frame
	sample.set_process(false)
	sample.set_physics_process(false)
	sample.goose.set_physics_process(false)
	sample.hero.set_physics_process(false)
	sample.reticle.update_target(sample.aim_at_screen(pixel))
	var frame: Image=await snapshot()
	frame.save_png("res://docs/captures/world_restart/aim28_muzzle.png")
	sample.reticle.guide_mesh.hide()
	sample.reticle.endpoint.hide()
	var hidden: Image=await snapshot()
	verify(changed(frame,hidden,Rect2i(Vector2i.ZERO,frame.get_size()))>15,"guide produces actual visible GPU pixels")
	print("AIM28_SCREEN_SPEED_PX_S ",velocities)
	print("AIM28 ",checks," checks; failures=",failures.size())
	quit(0 if failures.is_empty() else 1)
