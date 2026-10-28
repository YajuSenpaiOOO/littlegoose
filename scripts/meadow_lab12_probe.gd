extends "res://scripts/ground_lab_probe.gd"

func run() -> void:
	var sample: Node3D = load("res://scenes/sandbox/ground_style_lab.tscn").instantiate()
	root.add_child(sample)
	sample.hero.controls_enabled = false
	sample.terrain_enabled = true
	sample._rebuild_terrain()
	for i in 15: await physics_frame
	verify(sample.hero.is_on_floor(),"actor lands on real sloped collision surface")
	var space := sample.get_world_3d().direct_space_state
	var max_error := 0.
	var up_normals := true
	for point in [Vector2(-6,0),Vector2(7,-8),Vector2(6,7),Vector2(0,3),Vector2(-9,4),Vector2(10,1)]:
		var ray := PhysicsRayQueryParameters3D.create(Vector3(point.x,10,point.y),Vector3(point.x,-10,point.y),1)
		var hit: Dictionary = space.intersect_ray(ray)
		if hit.is_empty(): max_error = 100.; up_normals = false
		else:
			max_error = maxf(max_error,absf(hit.position.y-sample.meadow.height_at(point.x,point.y,true)))
			up_normals = up_normals and hit.normal.y>.85
	verify(max_error<.012 and up_normals,"mesh collision matches smooth height field and has upward gentle normals")
	var height_span: float = sample.meadow.height_at(7,-8,true)-sample.meadow.height_at(6,7,true)
	verify(height_span>1.5 and height_span<3.,"landscape has broad hills and a shallow lowland, not per-vertex noise")
	var road_safe := true
	for i in range(-14,15):
		var z := float(i)
		var x := sin(z*.25)*.9
		road_safe = road_safe and sample.meadow.normal_at(x,z,true).y>.99
	verify(road_safe,"central path stays a gentle longitudinal grade")
	var roots_match := true
	var heights: Array[float] = []
	for i in range(0,3600,31):
		var at: Transform3D = sample.grass.multimesh.get_instance_transform(i)
		roots_match = roots_match and absf(at.origin.y-sample.meadow.height_at(at.origin.x,at.origin.z,true))<.0001
		roots_match = roots_match and at.basis.y.normalized().dot(sample.meadow.normal_at(at.origin.x,at.origin.z,true))>.999
		heights.append(at.basis.y.length())
	verify(roots_match,"grass instances root on terrain and align to its slope")
	heights.sort()
	verify(heights.back()-heights.front()>.35,"grass has reproducible patch and individual height variation")
	var first: Transform3D = sample.grass.multimesh.get_instance_transform(0)
	sample._unhandled_input(event(KEY_H))
	var uniform: Transform3D = sample.grass.multimesh.get_instance_transform(0)
	sample._unhandled_input(event(KEY_H))
	verify(sample.grass.multimesh.get_instance_transform(0)==first and uniform!=first,"height variation toggle is reversible without random reshuffling")
	# Actual uphill walking on the left bank, then return to the same comparison view.
	sample.hero.position = Vector3(-2,sample.meadow.height_at(-2,0,true)+.08,0)
	sample.hero.reset_physics_interpolation()
	for i in 12: await physics_frame
	sample.hero.controls_enabled = true
	Input.parse_input_event(event(KEY_A))
	for i in 55: await physics_frame
	var release := event(KEY_A)
	release.pressed = false
	Input.parse_input_event(release)
	sample.hero.controls_enabled = false
	for i in 8: await physics_frame
	print("MEADOW12_UPHILL at=",sample.hero.position," floor=",sample.hero.is_on_floor()," expected_y=",sample.meadow.height_at(sample.hero.position.x,sample.hero.position.z,true))
	verify(sample.hero.position.x< -4.5 and sample.hero.is_on_floor() and sample.hero.position.y>.9 and absf(sample.hero.position.y-sample.meadow.height_at(sample.hero.position.x,sample.hero.position.z,true))<.03,"actual input walks uphill without hovering or falling through")
	# New geometry variants: roots embedded, silhouette distinct, texture shares ground.
	var vertices: Array[int] = []
	var modes_ok := true
	for key in [KEY_7,KEY_8,KEY_9]:
		sample._unhandled_input(event(key))
		vertices.append(sample.grass.multimesh.mesh.surface_get_array_len(0))
		var arrays: Array = sample.grass.multimesh.mesh.surface_get_arrays(0)
		var points: PackedVector3Array = arrays[Mesh.ARRAY_VERTEX]
		var min_y := 1.
		for point in points: min_y = minf(min_y,point.y)
		modes_ok = modes_ok and min_y< -.03 and sample.grass_material.get_shader_parameter("ground_paint")==sample.ground_materials[3].get_shader_parameter("paint")
	verify(modes_ok and vertices[0]!=vertices[1] and vertices[1]!=vertices[2],"three distinct blade meshes bury roots and share the actual ground texture")
	var texture: Texture2D = sample.grass_material.get_shader_parameter("ground_paint")
	verify(not sample.grass_material.shader.code.contains("ALPHA=") and texture!=null,"new grass uses opaque silhouette geometry")
	sample.hero.position = Vector3(0,sample.meadow.height_at(0,3,true)+.05,3)
	sample._update_camera(0,true)
	sample.set_process(false)
	sample.set_physics_process(false)
	sample.hero.set_physics_process(false)
	sample.hero.hide()
	sample.label.get_parent().hide()
	sample.camera.physics_interpolation_mode = Node.PHYSICS_INTERPOLATION_MODE_OFF
	sample.camera.reset_physics_interpolation()
	var trail := PackedVector4Array()
	for i in 8: trail.append(Vector4(1000,1000,-100,1))
	var results: Array = []
	var bend_ok := true
	var recovery_ok := true
	for key in [KEY_7,KEY_8,KEY_9]:
		sample._unhandled_input(event(key))
		var material: ShaderMaterial = sample.grass_material
		material.set_shader_parameter("wind_strength",0.)
		material.set_shader_parameter("clock",0.)
		material.set_shader_parameter("trail",trail)
		material.set_shader_parameter("walker",Vector3(1000,1000,1000))
		material.set_shader_parameter("touch_bounds",Vector4(1000,1000,1001,1001))
		var rest := await snapshot()
		var at: Vector3 = sample.grass.multimesh.get_instance_transform(0).origin
		var pixel := Vector2i(sample.camera.unproject_position(at)*Vector2(rest.get_size())/root.get_visible_rect().size)
		var area := Rect2i(pixel-Vector2i(70,70),Vector2i(140,140)).intersection(Rect2i(Vector2i.ZERO,rest.get_size()))
		material.set_shader_parameter("walker",at)
		material.set_shader_parameter("touch_bounds",Vector4(at.x-.8,at.z-.8,at.x+.8,at.z+.8))
		var bent := await snapshot()
		material.set_shader_parameter("walker",Vector3(1000,1000,1000))
		material.set_shader_parameter("touch_bounds",Vector4(1000,1000,1001,1001))
		var recovered := await snapshot()
		var changed_pixels := changed(rest,bent,area)
		var recovery_pixels := changed(rest,recovered,area)
		bend_ok = bend_ok and changed_pixels>10
		recovery_ok = recovery_ok and recovery_pixels==0
		results.append({"kind":sample.grass_variant,"bent":changed_pixels,"recovery":recovery_pixels})
	verify(bend_ok,"all three new grass shapes visibly bend in actual rendering on sloped terrain")
	verify(recovery_ok,"all three shapes return to pixel-identical resting frames")
	sample._unhandled_input(event(KEY_T))
	for i in 3: await physics_frame
	var flat_ok := true
	for i in range(0,3600,31): flat_ok = flat_ok and absf(sample.grass.multimesh.get_instance_transform(i).origin.y)<.0001
	var hit: Dictionary = space.intersect_ray(PhysicsRayQueryParameters3D.create(Vector3(-6,10,0),Vector3(-6,-10,0),1))
	verify(flat_ok and not hit.is_empty() and absf(hit.position.y)<.001,"T restores real flat ground collision and roots together")
	print("MEADOW12_COLLISION_ERROR ",max_error," DEFORMATION ",JSON.stringify(results))
	print(JSON.stringify({"checks":checks,"failures":failures}))
	quit(0 if failures.is_empty() else 1)
