extends "res://scripts/ground_lab_probe.gd"
func check_roots(sample: Node3D) -> void:
	var seam_error := 0.
	var floor_error := 0.
	var terrain_span := 0.
	for piece in sample.root_pieces:
		var arrays: Array = piece.node.mesh.surface_get_arrays(0)
		var vertices: PackedVector3Array = arrays[Mesh.ARRAY_VERTEX]
		var uvs: PackedVector2Array = arrays[Mesh.ARRAY_TEX_UV]
		var last := 0.
		var first := 1.
		for uv in uvs:
			last = maxf(last,uv.y)
			first = minf(first,uv.y)
		for i in vertices.size():
			var world: Vector3 = piece.node.to_global(vertices[i])
			if absf(uvs[i].y-first)<.00001:
				var sprite_seam: Vector3 = sample._pixel_world(piece.sprite,Vector2(0,uvs[i].y*piece.sprite.texture.get_height()))
				seam_error = maxf(seam_error,absf(world.y-sprite_seam.y))
				terrain_span = maxf(terrain_span,absf(sample.meadow.height_at(world.x,world.z,sample.terrain_enabled)-piece.node.global_position.y))
			if absf(uvs[i].y-last)<.00001:
				floor_error = maxf(floor_error,absf(world.y-sample.meadow.height_at(world.x,world.z,sample.terrain_enabled)-.018))
	verify(seam_error<.00001 and floor_error<.0001,"all tree roots share the sprite seam and reach terrain at their outer edge")
	if sample.terrain_enabled: verify(terrain_span>.05,"regression includes slopes that previously split the seam")

func run() -> void:
	var sample: Node3D = load("res://scenes/sandbox/grounded_path17.tscn").instantiate()
	root.add_child(sample)
	sample.hero.controls_enabled = false
	for i in 16: await physics_frame
	verify(sample.house_variant==0 and sample.art_style==1 and sample.hero.is_on_floor(),"selected house1 and environment style2 remain playable")
	check_roots(sample)
	verify(sample.planting.size()>5900 and sample.grass.multimesh.instance_count==sample.planting.size(),"short border grass joins the existing reactive batch")
	var clear_center := true
	for p in sample.planting: clear_center = clear_center and sample.meadow.route_distance(Vector2(p.origin.x,p.origin.z))>=.839
	verify(clear_center,"route center remains clear of added grass")
	for at in [Vector2(-7.9,-2.5),Vector2(7,-5),Vector2(0,-9)]:
		sample._teleport15(at)
		sample._update_prop_contacts()
		var floor_error := 0.
		var projection_error := 0.
		for prop in sample.props15:
			for foot in prop.feet16:
				var p: Vector3 = sample._depth_fitted_point(prop,foot.pixel)
				var query := PhysicsRayQueryParameters3D.create(p+Vector3.UP*2.,p-Vector3.UP*2.,1)
				var hit: Dictionary = sample.get_world_3d().direct_space_state.intersect_ray(query)
				floor_error = maxf(floor_error,absf(p.y-hit.position.y) if not hit.is_empty() else 1000.)
				projection_error = maxf(projection_error,sample.camera.unproject_position(p).distance_to(sample.camera.unproject_position(sample._pixel_world(prop.sprite,foot.pixel))))
		print("FOOT_ERRORS ",at," height=",floor_error," pixels=",projection_error)
		verify(floor_error<.001 and projection_error<.01,"reconstructed shadow feet match terrain AND painted feet from %s"%at)
	verify(sample.fitted_cards.size()==4 and not sample.prop_volumes[0].visible and sample.fitted_cards[0].card.cast_shadow==GeometryInstance3D.SHADOW_CASTING_SETTING_SHADOWS_ONLY,"depth-fitted alpha silhouettes replace generic furniture boxes")
	var started := Time.get_ticks_usec()
	for i in 6: sample._update_prop_contacts()
	print("CONTACT_UPDATE_AVERAGE_MS ",(Time.get_ticks_usec()-started)/6000.)
	sample._unhandled_input(event(KEY_T))
	check_roots(sample)
	sample._unhandled_input(event(KEY_T))
	check_roots(sample)
	sample._teleport15(Vector2(-7.9,-2.5))
	sample._update_prop_contacts()
	sample.set_contact(false)
	verify(not sample.fitted_cards[0].card.visible and not sample.root_pieces[0].node.visible,"V disables new reconstructed shadows and roots")
	sample.set_contact(true)
	sample._unhandled_input(event(KEY_P))
	verify(not sample.fitted_cards[0].card.is_visible_in_tree() and not sample.contact_marks[0].mark.visible,"P hides fitted cast shadows and foot contact marks together")
	sample._unhandled_input(event(KEY_P))
	sample._teleport15(Vector2(-4.7,-2.6))
	sample._update_prop_contacts()
	sample.set_process(false)
	sample.set_physics_process(false)
	sample.hero.set_physics_process(false)
	var first: Image = await snapshot()
	for entry in sample.fitted_cards: entry.card.hide()
	var no_shadow: Image = await snapshot()
	for entry in sample.fitted_cards: entry.card.show()
	var restored: Image = await snapshot()
	var full := Rect2i(Vector2i.ZERO,first.get_size())
	verify(changed(first,no_shadow,full)>10,"actual GPU render contains the new alpha silhouette shadows")
	verify(changed(first,restored,full)==0,"restoring shadow cards returns an identical frame")
	sample._unhandled_input(event(KEY_J))
	var old_path: Image = await snapshot()
	sample._unhandled_input(event(KEY_J))
	var new_path: Image = await snapshot()
	verify(changed(first,old_path,full)>1000 and changed(first,new_path,full)==0,"GPU soil comparison changes path and restores deterministically")
	print("GROUND17_PROBE ",checks," checks; failures=",failures.size())
	quit(0 if failures.is_empty() else 1)
