extends "res://scripts/ground_lab_probe.gd"
func run() -> void:
	var sample: Node3D = load("res://scenes/world/world24.tscn").instantiate()
	root.add_child(sample)
	while not is_instance_valid(sample.fx_layer): await physics_frame
	sample.start_combat()
	sample.hero.controls_enabled = false
	for enemy in sample.enemies:
		enemy.set_physics_process(false)
		enemy.velocity = Vector3.ZERO
	var victim: CharacterBody3D = sample.enemies[2]
	var point: Vector2 = sample.camera.unproject_position(victim.position+Vector3.UP*.65)
	Input.warp_mouse(point*Vector2(root.size)/root.get_visible_rect().size)
	for i in 20: await physics_frame
	var press := InputEventMouseButton.new()
	press.button_index = MOUSE_BUTTON_LEFT
	press.pressed = true
	Input.parse_input_event(press)
	for i in 4: await physics_frame
	var volley: Image = await snapshot()
	volley.save_png("res://docs/captures/world_restart/combat24_pearl.png")
	for i in 100:
		await physics_frame
		if sample.landed_hits>0: break
	press.pressed = false
	Input.parse_input_event(press)
	verify(sample.landed_hits>0,"real mouse volley hits through native 3D collision")
	sample._reset_impact_state()
	sample.set_process(false)
	sample.set_physics_process(false)
	sample.hero.set_physics_process(false)
	sample.feedback.set_process(false)
	sample.feedback.queue_redraw()
	sample.fx_layer.process_mode = Node.PROCESS_MODE_DISABLED
	for node in sample.anchors:
		if is_instance_valid(node) and node.projectile: node.hide()
	var frame: Image = await snapshot()
	frame.save_png("res://docs/captures/world_restart/combat24_impact.png")
	sample.fx_layer.hide()
	var hidden: Image = await snapshot()
	verify(changed(frame,hidden,Rect2i(Vector2i.ZERO,frame.get_size()))>100,"old pearl, muzzle, fragments and juice produce visible GPU output")
	sample.fx_layer.show()
	print("COMBAT24_CAPTURE ",checks," checks; failures=",failures.size())
	quit(0 if failures.is_empty() else 1)
