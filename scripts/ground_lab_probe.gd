extends SceneTree
var failures: Array[String] = []
var checks := 0
func _initialize() -> void: run.call_deferred()
func verify(ok: bool,message: String) -> void:
	checks += 1
	if not ok: failures.append(message)
	print("PASS " if ok else "FAIL ",message)
func event(key: Key) -> InputEventKey:
	var result := InputEventKey.new()
	result.physical_keycode = key
	result.pressed = true
	return result
func snapshot() -> Image:
	for i in 3: await process_frame
	await RenderingServer.frame_post_draw
	return root.get_texture().get_image()
func changed(a: Image,b: Image,area: Rect2i) -> int:
	var count := 0
	for y in range(area.position.y,area.end.y):
		for x in range(area.position.x,area.end.x):
			if a.get_pixel(x,y)!=b.get_pixel(x,y): count += 1
	return count
func temporal_jerk(frames: Array[Image],area: Rect2i) -> float:
	var score := 0.
	for i in range(1,frames.size()-1):
		for y in range(area.position.y,area.end.y):
			for x in range(area.position.x,area.end.x):
				var before := frames[i-1].get_pixel(x,y)
				var now := frames[i].get_pixel(x,y)
				var after := frames[i+1].get_pixel(x,y)
				score += absf(after.r-2*now.r+before.r)+absf(after.g-2*now.g+before.g)+absf(after.b-2*now.b+before.b)
	return score/float(area.size.x*area.size.y*(frames.size()-2))
func run() -> void:
	var sample: Node3D = load("res://scenes/sandbox/ground_style_lab.tscn").instantiate()
	root.add_child(sample)
	# Historical lab11 checks remain a regression baseline, explicitly using its grass.
	sample.grass_variant = 0
	sample._refresh_planting()
	sample.set_candidate(3)
	sample.hero.controls_enabled = false
	for i in 15: await physics_frame
	verify(sample.hero.is_on_floor(),"actual 3D actor lands on lab ground")
	verify(sample.camera.projection==Camera3D.PROJECTION_PERSPECTIVE and is_equal_approx(sample.camera.rotation_degrees.x,-25.),"lab preserves 25-degree perspective")
	verify(sample.trees.is_empty() and sample.house_meshes.is_empty() and sample.target==null,"no mixed house tree or combat visuals are instantiated")
	verify(root.msaa_3d==Viewport.MSAA_4X,"scene uses real 4x MSAA for geometry edges")
	verify(sample.grass.multimesh.instance_count==3600 and sample.grass.multimesh.mesh.surface_get_array_len(0)==75,"3600 instances use five curved opaque blades")
	var shader: String = sample.grass_material.shader.code
	verify(not shader.contains("ALPHA=") and not shader.contains("sampler") and not shader.contains("discard"),"new grass has no transparency texture sampling or alpha clipping")
	var first: Transform3D = sample.grass.multimesh.get_instance_transform(0)
	verify(first.basis!=sample.grass.multimesh.get_instance_transform(1).basis,"grass orientations are randomized rather than parallel rows")
	var camera_position: Vector3 = sample.camera.position
	var hero_position: Vector3 = sample.hero.position
	var energy: float = sample.sun.light_energy
	var fairness := true
	var layers := true
	for i in 6:
		sample.set_candidate(i)
		fairness = fairness and sample.camera.position==camera_position and sample.hero.position==hero_position and sample.sun.light_energy==energy and sample.grass.multimesh.get_instance_transform(0)==first
	for i in 3:
		var texture: Texture2DArray = sample.grass_materials[i].get_shader_parameter("paint")
		layers = layers and texture.get_layers()==4 and texture.get_layer_data(0).has_mipmaps()
	verify(fairness,"candidate switches preserve camera character light and planting transforms")
	verify(layers,"each candidate uses four isolated mipmapped grass layers")
	sample._unhandled_input(event(KEY_J))
	verify(not sample.solid_grass and sample.grass.multimesh.mesh.surface_get_array_len(0)==12,"J restores original crossed cards for comparison")
	sample._unhandled_input(event(KEY_J))
	verify(sample.solid_grass and sample.grass.multimesh.get_instance_transform(0)==first,"J restores opaque blades without moving planting positions")
	verify(sample.ground_materials[5].get_shader_parameter("flat_ground")==true,"sixth ground is actual flat color rather than a detailed bitmap")
	sample._unhandled_input(event(KEY_G))
	sample.set_candidate(0)
	verify(not sample.grass.visible,"ground-only view persists across candidate switches")
	sample._unhandled_input(event(KEY_G))
	verify(sample.grass.visible,"G restores reactive plants")
	# Move through the actual area occupied by grass.
	sample.hero.controls_enabled = true
	sample.hero.position = Vector3(-2.2,.05,3.)
	sample.hero.reset_physics_interpolation()
	var press := event(KEY_D)
	Input.parse_input_event(press)
	for i in 25: await physics_frame
	var release := event(KEY_D)
	release.pressed = false
	Input.parse_input_event(release)
	sample.hero.controls_enabled = false
	verify(sample.hero.position.x > -1.0 and sample.hero.is_on_floor(),"actual actor can cross the grass without plant collisions")
	# Freeze all time and camera input to verify GPU deformation and recovery.
	sample.set_process(false)
	sample.set_physics_process(false)
	sample.hero.set_physics_process(false)
	sample.hero.hide()
	sample.label.get_parent().hide()
	sample.camera.position = camera_position
	sample.camera.physics_interpolation_mode = Node.PHYSICS_INTERPOLATION_MODE_OFF
	sample.camera.reset_physics_interpolation()
	var trail := PackedVector4Array()
	for i in 8: trail.append(Vector4(1000,1000,-100,1))
	var deformation_results: Array = []
	var all_deform := true
	var all_recover := true
	for style in 6:
		sample.set_candidate(style)
		var material: ShaderMaterial = sample.grass_material
		material.set_shader_parameter("wind_strength",0.)
		material.set_shader_parameter("clock",0.)
		material.set_shader_parameter("trail",trail)
		material.set_shader_parameter("walker",Vector3(1000,1000,1000))
		material.set_shader_parameter("touch_bounds",Vector4(1000,1000,1001,1001))
		var rest := await snapshot()
		var at: Vector3 = first.origin
		var ratio := Vector2(rest.get_size())/root.get_visible_rect().size
		var pixel := Vector2i(sample.camera.unproject_position(at)*ratio)
		var area := Rect2i(pixel-Vector2i(70,70),Vector2i(140,140)).intersection(Rect2i(Vector2i.ZERO,rest.get_size()))
		material.set_shader_parameter("walker",at)
		material.set_shader_parameter("touch_bounds",Vector4(at.x-.8,at.z-.8,at.x+.8,at.z+.8))
		var pressed := await snapshot()
		material.set_shader_parameter("walker",Vector3(1000,1000,1000))
		material.set_shader_parameter("touch_bounds",Vector4(1000,1000,1001,1001))
		var recovered := await snapshot()
		var deform := changed(rest,pressed,area)
		var recover := changed(rest,recovered,area)
		deformation_results.append({"style":style+1,"changed_pixels":deform,"recovery_pixels":recover})
		all_deform = all_deform and deform>10
		all_recover = all_recover and recover==0
	verify(all_deform,"all six palettes visibly bend on contact")
	verify(all_recover,"all six palettes recover to pixel-identical resting frames")
	# Actual rendered static frame stability, then record a slow subpixel camera pan.
	sample.ground.hide()
	var at: Vector3 = first.origin
	var area := Rect2i(Vector2i(sample.camera.unproject_position(at)*Vector2(0.9,0.9))-Vector2i(65,65),Vector2i(130,130))
	var scores: Array = []
	for solid in [false,true]:
		sample.solid_grass = solid
		sample.set_candidate(4)
		sample.grass_material.set_shader_parameter("wind_strength",0.)
		sample.grass_material.set_shader_parameter("clock",0.)
		sample.grass_material.set_shader_parameter("walker",Vector3(1000,1000,1000))
		sample.grass_material.set_shader_parameter("touch_bounds",Vector4(1000,1000,1001,1001))
		sample.grass_material.set_shader_parameter("trail",trail)
		var still := await snapshot()
		verify(changed(still,await snapshot(),area)==0,"stationary grass frame remains stable, solid="+str(solid))
		var frames: Array[Image] = []
		for i in 9:
			sample.camera.position = camera_position+Vector3.RIGHT*(float(i)*.006)
			frames.append(await snapshot())
		scores.append(temporal_jerk(frames,area))
	print("GROUND_LAB_DEFORMATION ",JSON.stringify(deformation_results))
	print("GROUND_LAB_PAN old_cards=",scores[0]," opaque_blades=",scores[1]," (different silhouettes; diagnostic, not a universal flicker guarantee)")
	print(JSON.stringify({"checks":checks,"failures":failures}))
	quit(0 if failures.is_empty() else 1)
