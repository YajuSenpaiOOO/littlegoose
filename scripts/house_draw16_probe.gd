extends "res://scripts/ground_lab_probe.gd"
func run() -> void:
	var sample: Node3D = load("res://scenes/sandbox/house_draw16.tscn").instantiate()
	root.add_child(sample)
	sample.hero.controls_enabled = false
	for i in 16: await physics_frame
	verify(sample.draw_textures.size()==3 and sample.art_style==1,"three new houses use selected style2 ground and trees")
	verify(sample.camera.projection==Camera3D.PROJECTION_PERSPECTIVE and is_equal_approx(sample.camera.rotation_degrees.x,-25.),"camera depression is 25 degrees; house yaw is zero")
	verify(sample.hero.is_on_floor() and sample.grass.multimesh.instance_count==5600 and sample.mixed_grass,"playable terrain and mixed reactive grass remain intact")
	var original_camera: Transform3D = sample.camera.transform
	var original_root: Vector3 = sample.cottage_root.position
	var widths: Array[float] = []
	var textures: Array[Texture2D] = []
	for index in 3:
		sample._set_house_variant(index)
		widths.append(sample.cottage_body.get_child(0).shape.size.x)
		textures.append(sample.house_art.texture)
		verify(sample.shadow_volume.get_child_count()==3 and sample.house_art.cast_shadow==GeometryInstance3D.SHADOW_CASTING_SETTING_OFF and sample.house_art.rotation_degrees.y==0.,"house%d has zero-yaw sprite and its own wall/roof/chimney shadow volume"%index)
	verify(widths[0]!=widths[1] and widths[1]!=widths[2] and textures[0]!=textures[1] and textures[1]!=textures[2],"switching houses changes both painted design and fitted footprint")
	verify(sample.camera.transform==original_camera and sample.cottage_root.position==original_root,"house comparison preserves camera and doorway anchor")
	for index in 3:
		sample._set_house_variant(index)
		sample._teleport15(Vector2(-4.7,-3.4))
		for i in 8: await physics_frame
		sample.hero.controls_enabled = true
		Input.parse_input_event(event(KEY_W))
		for i in 40: await physics_frame
		var release := event(KEY_W)
		release.pressed = false
		Input.parse_input_event(release)
		sample.hero.controls_enabled = false
		for i in 6: await physics_frame
		verify(sample.hero.position.z> -5.1 and sample.hero.position.z< -4.4 and sample.hero.is_on_floor(),"actual movement stops at house%d front footprint"%index)
	verify(sample.root_pieces.size()==sample.trees.size(),"only trees use root strips; furniture feet are not flattened")
	verify(sample.contact_marks.size()==13,"all thirteen sampled furniture support points have individual contacts")
	for at in [Vector2(0,3),Vector2(-4.7,-2.6),Vector2(7,-4)]:
		sample._teleport15(at)
		sample._update_prop_contacts()
		var floor_error := 0.
		var screen_error := 0.
		for foot in sample.contact_marks:
			var p: Vector3 = foot.world
			floor_error = maxf(floor_error,absf(p.y-sample.meadow.height_at(p.x,p.z,sample.terrain_enabled)-.014))
			var painted: Vector3 = sample._pixel_world(foot.prop.sprite,foot.pixel)
			screen_error = maxf(screen_error,sample.camera.unproject_position(p).distance_to(sample.camera.unproject_position(painted)))
		verify(floor_error<.0001 and screen_error<2.,"support marks match terrain and painted foot projections from view %s"%at)
	sample.set_contact(false)
	verify(not sample.shadow_volume.visible and not sample.contact_marks[0].mark.visible and not sample.prop_volumes[0].visible,"contact toggle disables both house and furniture fitted shadows")
	sample.set_contact(true)
	verify(sample.shadow_volume.visible and sample.contact_marks[0].mark.visible and sample.prop_volumes[0].visible,"contact toggle restores fitted shadows")
	var volume_id: int = sample.prop_volumes[0].get_child(0).get_instance_id()
	sample.camera_distance = 24.
	sample._update_camera(0,true)
	sample._update_prop_contacts()
	verify(sample.prop_volumes[0].get_child(0).get_instance_id()==volume_id,"zoom updates existing furniture shadow geometry without rebuilding nodes")
	var zoom_error := 0.
	for foot in sample.contact_marks:
		zoom_error = maxf(zoom_error,sample.camera.unproject_position(foot.world).distance_to(sample.camera.unproject_position(sample._pixel_world(foot.prop.sprite,foot.pixel))))
	verify(zoom_error<2.,"foot contacts remain aligned after perspective zoom")
	sample.camera_distance = 15.
	sample._unhandled_input(event(KEY_P))
	await process_frame
	verify(not sample.props15[0].root.visible and not sample.contact_marks[0].mark.visible and sample.props15[0].body.collision_layer==0,"hiding props removes their contacts shadows and collision")
	sample._unhandled_input(event(KEY_P))
	sample._teleport15(Vector2(-4.7,-2.6))
	sample._set_house_variant(0)
	sample._update_prop_contacts()
	sample.set_process(false)
	sample.hero.set_physics_process(false)
	sample.grass_material.set_shader_parameter("wind_strength",0.)
	var first: Image = await snapshot()
	sample._set_house_variant(1)
	var second: Image = await snapshot()
	sample._set_house_variant(0)
	var restored: Image = await snapshot()
	var rect := Rect2i(Vector2i.ZERO,first.get_size())
	verify(changed(first,second,rect)>1000,"actual GPU render distinguishes house designs")
	verify(changed(first,restored,rect)==0,"returning to same house restores identical rendered frame")
	print("HOUSE16_PROBE ",checks," checks; failures=",failures.size())
	quit(0 if failures.is_empty() else 1)
