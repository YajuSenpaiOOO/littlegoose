extends "res://scripts/ground_lab_probe.gd"

func run() -> void:
	var sample: Node3D = load("res://scenes/sandbox/forest_styles14.tscn").instantiate()
	root.add_child(sample)
	sample.hero.controls_enabled = false
	for i in 15: await physics_frame
	verify(sample.style_packs.size()==4,"original cartoon plus three complete generated style sets are loaded")
	verify(sample.mixed_grass and sample.grass_material.get_shader_parameter("mixed_grass")==true,"short and tall grass coexist by default in one reactive batch")
	var tall := 0
	var tags: Array[Color] = []
	for i in sample.grass.multimesh.instance_count:
		var tag: Color = sample.grass.multimesh.get_instance_custom_data(i)
		tags.append(tag)
		if tag.b>.5: tall += 1
	var ratio := float(tall)/float(tags.size())
	verify(ratio>.15 and ratio<.45,"tall grass is a minority mixed among ground-cover grass")
	var camera_at: Vector3 = sample.camera.position
	var hero_at: Vector3 = sample.hero.position
	var first_tree: Transform3D = sample.trees[0].root.transform
	var first_grass: Transform3D = sample.grass.multimesh.get_instance_transform(0)
	var house_at: Transform3D = sample.cottage_root.transform
	var lighting: Color = sample.sun.light_color
	var stable := true
	var material_match := true
	var alpha_bounds := true
	for style in 4:
		sample.set_art_style(style)
		stable = stable and sample.camera.position==camera_at and sample.hero.position==hero_at and sample.trees[0].root.transform==first_tree and sample.grass.multimesh.get_instance_transform(0)==first_grass and sample.cottage_root.transform==house_at and sample.sun.light_color==lighting
		material_match = material_match and sample.ground_materials[3].get_shader_parameter("paint")==sample.style_packs[style].ground and sample.grass_material.get_shader_parameter("ground_paint")==sample.style_packs[style].ground
		material_match = material_match and sample.house_art.texture==sample.style_packs[style].textures.cottage and sample.trees[0].visual.texture==sample.style_packs[style].textures.oak and sample.trees[1].visual.texture==sample.style_packs[style].textures.young
		for id in ["oak","young","cottage"]:
			var texture: Texture2D = sample.style_packs[style].textures[id]
			var profile: Dictionary = sample.style_packs[style].profiles[id]
			var bounds: Array = profile.bounds
			alpha_bounds = alpha_bounds and texture.get_image().has_mipmaps() and profile.height>0 and bounds[0]>0 and bounds[0]+bounds[2]<texture.get_width()
	verify(stable,"all art switches preserve camera actor planting roots house collision and lighting")
	verify(material_match,"each switch updates ground, both tree shapes, cottage and grass root color together")
	verify(alpha_bounds,"all tree cells have uncropped transparent side margins and mipmaps")
	var same_tags := true
	for i in tags.size(): same_tags = same_tags and tags[i]==sample.grass.multimesh.get_instance_custom_data(i)
	verify(same_tags,"short/tall species distribution is identical in every art direction")
	sample._unhandled_input(event(KEY_M))
	verify(not sample.mixed_grass and not sample.grass_material.get_shader_parameter("mixed_grass"),"M disables species mixing without reallocating planting")
	sample._unhandled_input(event(KEY_M))
	verify(sample.mixed_grass and sample.grass_material.get_shader_parameter("mixed_grass"),"M restores the same mixed planting")
	sample._unhandled_input(event(KEY_7))
	verify(not sample.mixed_grass and sample.grass_variant==1,"single short-grass comparison remains available")
	sample._unhandled_input(event(KEY_M))
	# Freeze actor and time; verify real renders differ and original style is reversible.
	sample.set_process(false)
	sample.set_physics_process(false)
	sample.hero.set_physics_process(false)
	sample.camera.physics_interpolation_mode = Node.PHYSICS_INTERPOLATION_MODE_OFF
	sample.camera.reset_physics_interpolation()
	sample.label.get_parent().hide()
	sample.wind_enabled = false
	sample.set_candidate(3)
	sample.set_art_style(0)
	var baseline := await snapshot()
	var area := Rect2i(0,0,baseline.get_width(),baseline.get_height()-160)
	var differences: Array[int] = []
	for style in range(1,4):
		sample.set_art_style(style)
		var frame := await snapshot()
		differences.append(changed(baseline,frame,area))
	sample.set_art_style(0)
	var restored := await snapshot()
	verify(differences.min()>10000,"all three new art sets visibly change actual rendered environment pixels")
	verify(changed(baseline,restored,area)==0,"returning to original cartoon restores pixel-identical frozen view")
	# Mixed-height grass still deforms and recovers in actual rendering.
	var material: ShaderMaterial = sample.grass_material
	var at: Vector3 = sample.grass.multimesh.get_instance_transform(0).origin
	var trail := PackedVector4Array()
	for i in 8: trail.append(Vector4(1000,1000,-100,1))
	material.set_shader_parameter("wind_strength",0.)
	material.set_shader_parameter("trail",trail)
	material.set_shader_parameter("walker",Vector3(1000,1000,1000))
	material.set_shader_parameter("touch_bounds",Vector4(1000,1000,1001,1001))
	var rest := await snapshot()
	var pixel := Vector2i(sample.camera.unproject_position(at)*Vector2(rest.get_size())/root.get_visible_rect().size)
	var roi := Rect2i(pixel-Vector2i(70,70),Vector2i(140,140)).intersection(Rect2i(Vector2i.ZERO,rest.get_size()))
	material.set_shader_parameter("walker",at)
	material.set_shader_parameter("touch_bounds",Vector4(at.x-.8,at.z-.8,at.x+.8,at.z+.8))
	var bent := await snapshot()
	material.set_shader_parameter("walker",Vector3(1000,1000,1000))
	material.set_shader_parameter("touch_bounds",Vector4(1000,1000,1001,1001))
	var recovered := await snapshot()
	var bend_pixels := changed(rest,bent,roi)
	verify(bend_pixels>10 and changed(rest,recovered,roi)==0,"mixed grass visibly bends and recovers without residual pixels")
	print("FOREST14 mixed_tall=",tall," total=",tags.size()," changed_views=",differences," bend_pixels=",bend_pixels)
	print(JSON.stringify({"checks":checks,"failures":failures}))
	quit(0 if failures.is_empty() else 1)
