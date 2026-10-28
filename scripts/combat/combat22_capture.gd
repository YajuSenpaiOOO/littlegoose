extends "res://scripts/ground_lab_probe.gd"
func run() -> void:
	var sample: Node3D = load("res://scenes/world/world22.tscn").instantiate()
	root.add_child(sample)
	while not sample.combat_ready or not is_instance_valid(sample.feedback): await physics_frame
	sample.start_combat()
	sample.hero.controls_enabled = false
	for i in 45: await physics_frame
	var victim: CharacterBody3D = sample.enemies[5]
	for enemy in sample.enemies: enemy.set_physics_process(false)
	var body: Vector3 = victim.position+Vector3.UP*(.6+victim.visual.position.y)
	var point: Vector2 = sample.camera.unproject_position(body)
	Input.warp_mouse(point*Vector2(root.size)/root.get_visible_rect().size)
	for i in 3: await process_frame
	verify(sample.get_viewport().get_mouse_position().distance_to(point)<3.,"real window mouse maps to projected enemy through viewport stretch")
	var press := InputEventMouseButton.new()
	press.button_index = MOUSE_BUTTON_LEFT
	press.pressed = true
	Input.parse_input_event(press)
	for i in 25:
		await physics_frame
		if sample.landed_hits>0: break
	press.pressed = false
	Input.parse_input_event(press)
	verify(sample.landed_hits>0 and sample.feedback_count>0,"actual rendered projectile emits hit feedback")
	sample.set_process(false)
	sample.set_physics_process(false)
	sample.hero.set_physics_process(false)
	sample.feedback.set_process(false)
	sample.feedback.queue_redraw()
	var frame: Image = await snapshot()
	frame.save_png("res://docs/captures/world_restart/combat22_impact.png")
	sample.feedback.bursts.clear()
	sample.feedback.marker = 0.
	sample.feedback.queue_redraw()
	var no_feedback: Image = await snapshot()
	verify(changed(frame,no_feedback,Rect2i(Vector2i.ZERO,frame.get_size()))>30,"hit marker and spark burst are visible in actual GPU output")
	print("COMBAT22_CAPTURE ",checks," checks; failures=",failures.size())
	quit(0 if failures.is_empty() else 1)
