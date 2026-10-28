extends "res://scripts/ground_lab_probe.gd"
func run() -> void:
	var sample: Node3D = load("res://scenes/world/world23.tscn").instantiate()
	root.add_child(sample)
	while not is_instance_valid(sample.reticle): await physics_frame
	sample.start_combat()
	sample.hero.controls_enabled = false
	for enemy in sample.enemies:
		enemy.set_physics_process(false)
		enemy.velocity = Vector3.ZERO
	var victim: CharacterBody3D = sample.enemies[0]
	var center: Vector2 = sample.meadow.landmarks.grove
	victim.position = Vector3(center.x,sample.meadow.walk_height(center,true)+.04,center.y)
	for i in range(1,6): sample.enemies[i].hit_area.collision_layer=0
	for i in 5: await physics_frame
	verify(sample.body_hit_3d and not sample.uses_planar_hits(),"default combat uses native 3D hit volumes")
	verify(victim.hit_area.get_child(0).shape is CapsuleShape3D,"enemy card owns a real capsule independent of physical locomotion")
	var body_y: float = victim.hit_area.position.y
	victim._pose("airborne",.38)
	verify(is_equal_approx(victim.hit_area.position.y,body_y),"visual jump does not drag the hit volume away from the body zone")
	sample.gentle_assist = false
	var worst := 0.
	for distance in [12.,18.,28.]:
		sample.camera_distance = distance
		sample._update_camera(0,true)
		var at := center+Vector2(3,1)
		var point := Vector3(at.x,sample.meadow.walk_height(at,true)+sample.AIM_CLEARANCE,at.y)
		var screen: Vector2 = sample.camera.unproject_position(point)
		var goal: Vector3 = sample.aim_at_screen(screen)
		var error: float = sample.camera.unproject_position(goal).distance_to(screen)
		worst = maxf(worst,error)
		verify(error<.05,"world aim projects to mouse at zoom "+str(distance))
		verify(absf(goal.y-sample.meadow.walk_height(Vector2(goal.x,goal.z),true)-.85)<.002,"floating target follows terrain at fixed clearance")
		sample.reticle.update_target(goal)
		verify(Vector2(sample.reticle.ground_point.x,sample.reticle.ground_point.z).distance_to(Vector2(goal.x,goal.z))<.001,"ground mark shares the actual aim point's horizontal coordinates")
	sample.camera_distance = 15.
	sample._update_camera(0,true)
	var origin: Vector3 = sample.projectile_origin()
	var old_spring: Vector2 = sample.goose.spring_velocity
	sample.fire_at(victim.position+Vector3.UP*.85)
	verify(sample.shots.size()==1 and sample.shots[0].node.position.distance_to(origin)<.001,"projectile starts at the visible familiar muzzle")
	verify(origin.distance_to(sample.hero.position+Vector3.UP*.85)>.2,"muzzle is spatially distinct from hero center")
	verify(sample.goose.spring_velocity.distance_to(old_spring)>.5,"firing gives the old familiar spring recoil")
	for i in 22: await physics_frame
	verify(victim.hp==8. and sample.landed_hits==1,"native 3D projectile hits an airborne card's capsule")
	victim.hp = 12.
	sample.fire_at(victim.position+Vector3.UP*2.4)
	for i in 22: await physics_frame
	verify(victim.hp==12.,"a shot truly above the capsule does not count as a hit")
	sample._clear_combat_shots()
	var tree_center := Vector2.ZERO
	for tree in sample.trees:
		var delta: Vector2 = Vector2(tree.root.position.x,tree.root.position.z)-center
		if delta.length()<10. or absf(delta.x)>17. or absf(delta.y)>12.: continue
		for child in tree.root.get_children():
			if child is StaticBody3D:
				var p: Vector3 = child.get_child(0).global_position
				tree_center = Vector2(p.x,p.z)
		break
	sample._teleport15(tree_center+Vector2(0,3))
	victim.position = Vector3(tree_center.x,sample.meadow.walk_height(tree_center-Vector2(0,3),true)+.04,tree_center.y-3.)
	sample.goose.update_follow(0.,victim.position,true)
	for i in 3: await physics_frame
	# Snap immediately before emission so the ray crosses the selected trunk center.
	sample.goose.update_follow(0.,victim.position,true)
	var old_blocks: int = sample.blocks
	sample.fire_at(victim.position+Vector3.UP*.85)
	for i in 22: await physics_frame
	verify(sample.blocks>old_blocks and victim.hp==12.,"real tree collision still blocks familiar shots")
	sample._unhandled_input(event(KEY_F10))
	verify(victim.debug_body.visible,"F10 reveals the actual capsule")
	sample._unhandled_input(event(KEY_F11))
	verify(not sample.body_hit_3d and sample.uses_planar_hits(),"F11 offers planar tolerance as an explicit comparison")
	sample._unhandled_input(event(KEY_Q))
	sample.reticle.update_target(sample.aim_at_screen(Vector2(800,500)))
	verify(not sample.reticle.visible,"Q switches from world reticle to screen cursor")
	sample._unhandled_input(event(KEY_Q))
	sample._unhandled_input(event(KEY_F5))
	verify(sample.enemies.size()==6 and sample.player_hp==100.,"familiar trial still resets the combat round")
	FileAccess.open("res://docs/combat23-validation.json",FileAccess.WRITE).store_string(JSON.stringify({"checks":checks,"failures":failures,"max_cursor_error_px":worst},"\t"))
	print("COMBAT23_PROBE ",checks," checks; failures=",failures.size())
	quit(0 if failures.is_empty() else 1)
