extends SceneTree
func _initialize() -> void: run.call_deferred()
func snapshot() -> Image:
	for i in 4: await process_frame
	await RenderingServer.frame_post_draw
	return root.get_texture().get_image()
func changed(a: Image,b: Image,area: Rect2i) -> int:
	var count := 0
	for y in range(area.position.y,area.end.y):
		for x in range(area.position.x,area.end.x):
			if a.get_pixel(x,y)!=b.get_pixel(x,y): count += 1
	return count
func run() -> void:
	var scene: Node3D = load("res://scenes/sandbox/perspective_playground.tscn").instantiate()
	root.add_child(scene)
	scene.hero.controls_enabled = false
	for i in 20: await physics_frame
	scene.set_process(false)
	scene.set_physics_process(false)
	scene.hero.set_physics_process(false)
	scene.hero.hide()
	scene.camera.reset_physics_interpolation()
	scene.label.get_parent().hide()
	var material: ShaderMaterial = scene.grass_material
	var trail := PackedVector4Array()
	for i in 8: trail.append(Vector4(1000,1000,-100,1))
	material.set_shader_parameter("trail",trail)
	material.set_shader_parameter("clock",0.)
	material.set_shader_parameter("walker",Vector3(1000,1000,1000))
	material.set_shader_parameter("touch_bounds",Vector4(1000,1000,1001,1001))
	var rest := await snapshot()
	var at: Vector3 = scene.grass.multimesh.get_instance_transform(0).origin
	var screen: Vector2 = scene.camera.unproject_position(at)
	var ratio := Vector2(rest.get_size())/root.get_visible_rect().size
	var pixel := Vector2i(screen*ratio)
	var area := Rect2i(pixel-Vector2i(65,65),Vector2i(130,130)).intersection(Rect2i(Vector2i.ZERO,rest.get_size()))
	material.set_shader_parameter("walker",at)
	material.set_shader_parameter("touch_bounds",Vector4(at.x-.8,at.z-.8,at.x+.8,at.z+.8))
	var pressed := await snapshot()
	material.set_shader_parameter("walker",Vector3(1000,1000,1000))
	material.set_shader_parameter("touch_bounds",Vector4(1000,1000,1001,1001))
	var recovered := await snapshot()
	var deformation := changed(rest,pressed,area)
	var recovery := changed(rest,recovered,area)
	rest.save_png("res://docs/captures/world_restart/perspective09_grass_rest.png")
	pressed.save_png("res://docs/captures/world_restart/perspective09_grass_pressed.png")
	print("3D_GRASS_RENDER deformation=",deformation," recovery=",recovery," region=",area)
	quit(0 if deformation>10 and recovery==0 else 1)
