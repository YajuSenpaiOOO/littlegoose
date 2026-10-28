extends "res://scripts/world/woodland46_probe.gd"
class LandmarkSample:
	extends "res://scripts/world/world62.gd"
	func _hero_script() -> Script: return LivingActor
	func fire_input_held() -> bool: return false

func shot62(tag: String) -> Image:
	var frame: Image=await snapshot()
	frame.save_png("res://docs/captures/world_restart/landmark62_"+tag+".png")
	return frame

func run() -> void:
	var sample: Node3D=LandmarkSample.new()
	root.add_child(sample)
	while not is_instance_valid(sample.landmark62) or not sample.landmark62.is_node_ready(): await physics_frame
	for i in 40: await physics_frame
	sample.label.get_parent().hide()
	sample.hero.controls_enabled=false
	var study: Node3D=sample.landmark62
	var tree: Dictionary=sample.landmark_tree
	var collider: CollisionShape3D
	for child in tree.root.get_children():
		if child is StaticBody3D: collider=child.get_child(0)
	var shape: Shape3D=collider.shape
	var position: Vector3=collider.position
	verify(not sample.bridge59.moving and not sample.bridge59.sparkling and not sample.bridge59.distant_glow,"water animation and mood effects parked")
	verify(sample.bridge59.bridge_style==0 and sample.bridge59.water_style==0,"rope bridge and storybook water retained")
	verify(sample.old_sign62.size()==7,"only the old post boards and labels are captured")
	verify(sample.meadow.get_script().resource_path=="res://scripts/world/world_surface21.gd","terrain remains approved original")
	verify(RenderingServer.get_current_rendering_method()=="gl_compatibility","Compatibility retained")
	sample.time55.preview_at(12.)
	sample.time55.visual_hour=12.
	sample.time55.apply_look()
	for i in 15: await physics_frame
	paused=true
	var images: Array[Image]=[]
	for i in 3:
		study.set_tree(i)
		images.append(await shot62("tree_"+str(i)))
		verify(tree.visual.texture.resource_path.contains(study.FILES[i]),"variant %d uses its dedicated art"%i)
		verify(tree.shadow19.texture==tree.visual.texture and study.root_piece.node.material_override.get_shader_parameter("paint")==tree.visual.texture,"variant %d shares paint with shadow and grounded roots"%i)
		verify(collider.shape==shape and collider.position==position,"variant %d preserves trunk collision"%i)
	var full := Rect2i(Vector2i.ZERO,images[0].get_size())
	verify(changed(images[0],images[1],full)>10000 and changed(images[1],images[2],full)>10000,"three trees visibly differ in game")
	study.set_old_tree(true)
	await shot62("old_tree")
	verify(tree.visual.texture==study.original.texture,"old tree comparison restores original texture")
	study.set_old_tree(false)
	study.set_tree(0)
	var focus: ShaderMaterial=sample.atmosphere41.focus_material
	var bounds: Vector4=focus.get_shader_parameter("landmark_bounds62")
	var root_bounds: Vector4=focus.get_shader_parameter("landmark_root62")
	focus.set_shader_parameter("landmark_bounds62",Vector4.ZERO)
	focus.set_shader_parameter("landmark_root62",Vector4.ZERO)
	var blurred: Image=await shot62("without_landmark_focus")
	focus.set_shader_parameter("landmark_bounds62",bounds)
	focus.set_shader_parameter("landmark_root62",root_bounds)
	var focused: Image=await shot62("with_landmark_focus")
	verify(changed(blurred,focused,full)>5000,"landmark focus preserves dedicated tree detail")
	paused=false
	sample.hero.position.x+=.3
	study._process(0.)
	verify(not study.review_view,"moving exits the asset review camera")
	sample.go_sign62()
	for i in 40: await physics_frame
	paused=true
	study.set_sign(false)
	var solid: Image=await shot62("sign_3d")
	study.set_sign(true)
	var painted: Image=await shot62("sign_painted")
	verify(changed(solid,painted,full)>500,"painted and solid sign visibly differ")
	var old_hidden := true
	for node in sample.old_sign62: old_hidden=old_hidden and not node.visible
	verify(old_hidden and study.sign_root.visible,"painted sign hides all old visuals")
	var post: MeshInstance3D=sample.old_sign62[0]
	verify(post.get_child_count()>0 and post.get_child(0) is StaticBody3D and post.get_child(0).collision_layer==2,"original post collision retained in painted mode")
	sample.time55.visual_hour=22.
	sample.time55.apply_look()
	await shot62("night_sign")
	var event := InputEventKey.new()
	event.pressed=true; event.alt_pressed=true; event.physical_keycode=KEY_7
	sample._unhandled_input(event)
	verify(study.variant==2 and not study.old_tree,"Alt7 selects flowering elder instead of bridge")
	event.physical_keycode=KEY_N
	sample._unhandled_input(event)
	verify(not study.painted_sign,"AltN selects original sign")
	var file := FileAccess.open("res://docs/landmark62-validation.json",FileAccess.WRITE)
	file.store_string(JSON.stringify({"checks":checks,"failures":failures,"tree_height":tree.height,"root_radius":shape.radius,"old_sign_visuals":sample.old_sign62.size()},"\t"))
	print("LANDMARK62 ",checks," checks; failures=",failures.size())
	quit(0 if failures.is_empty() else 1)
