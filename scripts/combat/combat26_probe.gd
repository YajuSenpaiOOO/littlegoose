extends "res://scripts/ground_lab_probe.gd"
func run() -> void:
	var sample: Node3D = load("res://scenes/world/world26.tscn").instantiate()
	root.add_child(sample)
	while not is_instance_valid(sample.trail_batch): await physics_frame
	sample.start_combat()
	sample.hero.controls_enabled = false
	for enemy in sample.enemies: enemy.set_physics_process(false)
	for i in 5: await physics_frame
	verify(not sample.hero_contact.visible and not sample.goose.shadow.visible,"hero and goose no longer overlay generic circles on silhouettes")
	verify(sample.goose.has_node("GroundedActorSilhouette"),"goose retains its authored wing silhouette")
	var victim: CharacterBody3D = sample.enemies[0]
	var center: Vector2 = sample.meadow.landmarks.grove
	victim.position = Vector3(center.x,sample.floor_height(center)+.04,center.y+1.)
	victim._pose("idle",0.)
	for i in 4: await physics_frame
	var point: Vector2 = sample.camera.unproject_position(victim.visual.global_position+Vector3.UP*.6)
	verify(sample.aim_model.sprite_contains(sample.camera,point,victim.visual),"test cursor covers an opaque enemy pixel")
	var aim: Vector3 = sample.aim_at_screen(point)
	verify(sample.camera.unproject_position(aim).distance_to(point)<.02,"body-ray aim remains exactly under the cursor")
	var query := PhysicsRayQueryParameters3D.create(sample.camera.global_position,aim,8)
	query.collide_with_areas = true
	var hit: Dictionary = sample.get_world_3d().direct_space_state.intersect_ray(query)
	verify(not hit.is_empty() and hit.collider==victim.hit_area,"cursor depth comes from the actual native hit body")
	var hp: float = victim.hp
	sample.weapon_rng.seed=26
	sample.fire_at(aim)
	verify(sample.shots.size()==1 and sample.shots[0].shadow.has_meta("projected26"),"real pearl uses the directional ground shadow")
	var shot: Dictionary = sample.shots[0]
	var before: Vector3 = shot.shadow.global_position
	shot.node.position.y += .5
	sample._update_bullet_shadow(shot)
	var after: Vector3 = shot.shadow.global_position
	verify(Vector2(before.x,before.z).distance_to(Vector2(after.x,after.z))>.1,"bullet shadow follows sunlight when projectile height changes")
	verify(absf(after.y-sample.floor_height(Vector2(after.x,after.z))-.033)<.001,"bullet shadow stays on the actual terrain")
	shot.node.position.y -= .5
	for i in 90:
		await physics_frame
		if sample.landed_hits>0: break
	verify(victim.hp==hp-1.,"a pointer-targeted native 3D bullet still deals one damage")
	sample._unhandled_input(event(KEY_F6))
	verify(not sample.direct_body_aim,"F6 preserves the previous aiming model for comparison")
	sample._unhandled_input(event(KEY_F6))
	verify(sample.direct_body_aim,"F6 returns to direct body aiming")
	# Render a clean example, without hit flashes hiding the contact shadows.
	sample._clear_combat_shots()
	for i in 35: await physics_frame
	var image: Image = await snapshot()
	image.save_png("res://docs/captures/world_restart/combat26_shadows.png")
	print("COMBAT26 ",checks," checks; failures=",failures.size())
	quit(0 if failures.is_empty() else 1)
