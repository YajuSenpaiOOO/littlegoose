extends "res://scripts/ground_lab_probe.gd"
func run() -> void:
	var sample: Node3D = load("res://scenes/world/world25.tscn").instantiate()
	root.add_child(sample)
	while not is_instance_valid(sample.trail_batch): await physics_frame
	sample.start_combat()
	sample.hero.controls_enabled = false
	for enemy in sample.enemies: enemy.set_physics_process(false)
	for i in 5: await physics_frame
	var live: Array = sample.actor_shadows.filter(func(s): return is_instance_valid(s))
	verify(live.size()==5,"hero, goose and three enemies each own one silhouette")
	var max_error := 0.
	for x in range(-22,22,3):
		for z in range(-22,22,3):
			var at := Vector2(x+.123,z+.287)
			var query := PhysicsRayQueryParameters3D.create(Vector3(at.x,20,at.y),Vector3(at.x,-10,at.y),1)
			var hit := sample.get_world_3d().direct_space_state.intersect_ray(query)
			if not hit.is_empty(): max_error = maxf(max_error,absf(hit.position.y-sample.floor_height(at)))
	verify(max_error<.003,"cached triangle heights agree with native floor rays: "+str(max_error))
	sample.tracks.marks[0] = Vector4(sample.hero.position.x,sample.hero.position.z,sample.tracks.elapsed,0)
	sample.tracks.revision += 1
	sample._sync_tracks()
	verify(sample.ground_materials[0].get_shader_parameter("footprints_enabled"),"live footprints remain enabled")
	var old_elapsed: float = sample.tracks.elapsed
	sample.tracks.elapsed += sample.tracks.lifetime+.01
	sample._sync_tracks()
	verify(not sample.ground_materials[0].get_shader_parameter("footprints_enabled"),"expired footprints skip the empty fragment loop")
	sample.tracks.elapsed = old_elapsed
	sample.tracks.clear()
	sample._sync_tracks()
	for shadow in live:
		shadow._physics_process(0.)
		verify(shadow.mesh!=null and shadow.mesh.get_faces().size()==24,"silhouette projection produces a draped four-cell ground mesh")
	var victim: CharacterBody3D = sample.enemies[0]
	var at: Vector2 = sample.meadow.landmarks.grove
	victim.position = Vector3(at.x,sample.floor_height(at)+.04,at.y+1.)
	for i in 3: await physics_frame
	var hp: float = victim.hp
	sample.fire_at(victim.position+Vector3.UP*.8)
	for i in 90:
		await physics_frame
		if sample.landed_hits>0: break
	verify(victim.hp==hp-1. and sample.landed_hits==1,"batched cosmetics preserve actual native 3D projectile damage")
	verify(Engine.time_scale==1.,"ordinary hit does not freeze the simulation by default")
	sample._unhandled_input(event(KEY_X))
	sample.hitstop(.012)
	verify(Engine.time_scale==.05,"microstop comparison remains available")
	sample._reset_impact_state()
	sample._unhandled_input(event(KEY_X))
	# A silhouette moves with actual lift and the directional light, independently
	# of the stable ground foot used to judge aim.
	var shadow: MeshInstance3D = victim.get_node("GroundedActorSilhouette")
	victim._pose("idle",0.)
	shadow._physics_process(0.)
	var before: PackedVector3Array = shadow.mesh.surface_get_arrays(0)[Mesh.ARRAY_VERTEX]
	victim._pose("airborne",.5)
	shadow._physics_process(0.)
	var after: PackedVector3Array = shadow.mesh.surface_get_arrays(0)[Mesh.ARRAY_VERTEX]
	verify(Vector2(before[0].x,before[0].z).distance_to(Vector2(after[0].x,after[0].z))>.1,"jump height visibly shifts projected silhouette along sunlight")
	verify(shadow.ink.get_shader_parameter("silhouette")!=null,"current authored pose supplies the shadow alpha texture")
	var normal: Vector3 = sample.floor_normal(Vector2(victim.position.x,victim.position.z))
	sample._fit_contact(victim.shadow,victim.global_position,.026)
	verify(victim.shadow.global_basis.y.normalized().dot(normal)>.999,"ground contact faces the actual slope normal")
	# Freeze before both images, so only the silhouette visibility changes.
	sample.process_mode = Node.PROCESS_MODE_DISABLED
	var frame: Image = await snapshot()
	frame.save_png("res://docs/captures/world_restart/combat25_shadows.png")
	for s in sample.actor_shadows:
		if is_instance_valid(s): s.enabled=false; s.hide()
	var hidden: Image = await snapshot()
	verify(changed(frame,hidden,Rect2i(Vector2i.ZERO,frame.get_size()))>20,"actor shadows produce visible GPU output")
	print("COMBAT25 ",checks," checks; failures=",failures.size())
	quit(0 if failures.is_empty() else 1)
