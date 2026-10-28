extends "res://scripts/ground_lab_probe.gd"
func run() -> void:
	var sample: Node3D = load("res://scenes/world/world23.tscn").instantiate()
	root.add_child(sample)
	while not is_instance_valid(sample.reticle): await physics_frame
	sample.start_combat()
	sample.hero.controls_enabled = false
	for i in 35: await physics_frame
	for enemy in sample.enemies:
		enemy.set_physics_process(false)
		enemy.velocity = Vector3.ZERO
	var victim: CharacterBody3D = sample.enemies[5]
	var point: Vector2 = sample.camera.unproject_position(victim.position+Vector3.UP*.65)
	Input.warp_mouse(point*Vector2(root.size)/root.get_visible_rect().size)
	for i in 12: await physics_frame
	var press := InputEventMouseButton.new()
	press.button_index = MOUSE_BUTTON_LEFT
	press.pressed = true
	Input.parse_input_event(press)
	for i in 25:
		await physics_frame
		if sample.landed_hits>0: break
	press.pressed = false
	Input.parse_input_event(press)
	verify(sample.landed_hits>0,"actual mouse fires familiar projectile into a 3D body")
	sample.set_process(false)
	sample.set_physics_process(false)
	sample.hero.set_physics_process(false)
	sample.feedback.set_process(false)
	sample.feedback.queue_redraw()
	var frame: Image = await snapshot()
	frame.save_png("res://docs/captures/world_restart/combat23_world_cursor.png")
	sample._unhandled_input(event(KEY_F10))
	var bodies: Image = await snapshot()
	bodies.save_png("res://docs/captures/world_restart/combat23_hit_capsules.png")
	verify(changed(frame,bodies,Rect2i(Vector2i.ZERO,frame.get_size()))>100,"debug rendering shows actual 3D capsule volumes")
	sample._unhandled_input(event(KEY_F10))
	sample._unhandled_input(event(KEY_Q))
	sample.reticle.update_target(sample.reticle.target)
	sample.feedback.queue_redraw()
	var screen: Image = await snapshot()
	screen.save_png("res://docs/captures/world_restart/combat23_screen_cursor.png")
	verify(changed(frame,screen,Rect2i(Vector2i.ZERO,frame.get_size()))>30,"world and screen cursors render differently with the same frozen scene")
	sample._unhandled_input(event(KEY_Q))
	var empty: Vector2 = sample.meadow.landmarks.grove+Vector2(1,3)
	var target := Vector3(empty.x,sample.meadow.walk_height(empty,true)+.85,empty.y)
	sample.reticle.update_target(target)
	sample.feedback.marker = 0.
	sample.feedback.bursts.clear()
	sample.feedback.queue_redraw()
	var marker: Image = await snapshot()
	marker.save_png("res://docs/captures/world_restart/combat23_floating_marker.png")
	print("COMBAT23_CAPTURE ",checks," checks; failures=",failures.size())
	quit(0 if failures.is_empty() else 1)
