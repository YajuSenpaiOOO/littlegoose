extends "res://scripts/combat/perf25_probe.gd"
func run() -> void:
	DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
	sample = Updated.new()
	root.add_child(sample)
	while not is_instance_valid(sample.trail_batch): await physics_frame
	sample.start_combat()
	sample.hero.controls_enabled = false
	for enemy in sample.enemies: enemy.set_physics_process(false)
	for i in 40: await physics_frame
	await phase("idle",false,false)
	for batch in sample.grass_batches: batch.node.hide()
	await phase("no_grass",false,false)
	for batch in sample.grass_batches: batch.node.show()
	sample.sun.shadow_enabled = false
	await phase("no_sun_shadows",false,false)
	sample.sun.shadow_enabled = true
	sample.sun.directional_shadow_max_distance = 40.
	await phase("short_shadows",false,false)
	sample.sun.directional_shadow_max_distance = 70.
	for tree in sample.trees: tree.root.hide()
	await phase("no_trees",false,false)
	FileAccess.open("res://docs/perf25-ablation.json",FileAccess.WRITE).store_string(JSON.stringify(report,"\t"))
	quit()
