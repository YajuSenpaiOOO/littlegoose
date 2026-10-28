extends "res://scripts/ground_lab_probe.gd"
func run() -> void:
	var version := "40" if "--before" in OS.get_cmdline_user_args() else "41"
	var sample: Node3D = load("res://scenes/world/world%s.tscn"%version).instantiate()
	root.add_child(sample)
	for i in 100: await physics_frame
	sample.hero.controls_enabled = false
	sample.label.get_parent().hide()
	for key in ["home","trail","junction"]:
		sample._travel_region(key)
		for i in 45: await physics_frame
		var frame: Image = await snapshot()
		frame.save_png("res://docs/captures/world_restart/atmosphere%s_%s.png"%[version,key])
	print("ATMOSPHERE_CAPTURE_READY ",version)
	quit()
