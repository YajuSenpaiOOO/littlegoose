extends "res://scripts/ground_lab_probe.gd"
func run() -> void:
	var sample: Node3D = load("res://scenes/world/world21.tscn").instantiate()
	root.add_child(sample)
	for i in 120:
		await physics_frame
		if sample.combat_ready: break
	sample.start_combat()
	sample.hero.controls_enabled = false
	for i in 90: await physics_frame
	sample.combat_paused = true
	var frame: Image = await snapshot()
	frame.save_png("res://docs/captures/world_restart/combat21_grove.png")
	print("COMBAT21_CAPTURE_READY")
	quit()
