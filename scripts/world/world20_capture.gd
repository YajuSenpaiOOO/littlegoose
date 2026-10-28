extends "res://scripts/ground_lab_probe.gd"
func run() -> void:
	var sample: Node3D = load("res://scenes/world/world20.tscn").instantiate()
	root.add_child(sample)
	sample.hero.controls_enabled = false
	for key in ["home","junction","steps","grove"]:
		sample._travel_region(key)
		for i in 30: await physics_frame
		var frame: Image = await snapshot()
		frame.save_png("res://docs/captures/world_restart/world20_"+key+".png")
	print("WORLD20_CAPTURES_READY")
	quit()
