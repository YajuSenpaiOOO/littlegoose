extends "res://scripts/ground_lab_probe.gd"
func run() -> void:
	var sample: Node3D = load("res://scenes/world/world21.tscn").instantiate()
	root.add_child(sample)
	while not sample.combat_ready: await physics_frame
	sample.wave_state = "cleared"
	var at: Vector2 = sample.meadow.landmarks.grove+Vector2(-3,1)
	sample._teleport15(sample.meadow.landmarks.grove+Vector2(0,5.5))
	for i in 5: await physics_frame
	var ground_point := Vector3(at.x,sample.meadow.walk_height(at,true),at.y)
	var cursor: Vector2 = sample.camera.unproject_position(ground_point)
	var aim: Vector3 = sample.aim_at_screen(cursor)
	var error: float = sample.camera.unproject_position(aim).distance_to(cursor)
	print("OLD21_CURSOR_OFFSET_PX ",error)
	FileAccess.open("res://docs/aim22-diagnosis.json",FileAccess.WRITE).store_string(JSON.stringify({"old_cursor_error_logical_px":error,"screen_coordinates":[root.get_visible_rect().size.x,root.get_visible_rect().size.y]},"\t"))
	quit()
