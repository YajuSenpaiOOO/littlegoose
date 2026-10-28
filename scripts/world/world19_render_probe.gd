extends "res://scripts/ground_lab_probe.gd"
func run() -> void:
	var sample: Node3D = load("res://scenes/world/world19.tscn").instantiate()
	root.add_child(sample)
	sample.hero.controls_enabled = false
	sample._travel_region("trail")
	for i in 100: await physics_frame
	var fps := Engine.get_frames_per_second()
	var draw_calls := Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME)
	sample.set_process(false)
	sample.set_physics_process(false)
	sample.hero.set_physics_process(false)
	sample._update_camera(0,true)
	var fades: Array[float] = []
	var occluding := 0
	for tree in sample.trees:
		var fade: float = tree.visual.material_override.get_shader_parameter("fade")
		fades.append(fade)
		if fade<.5: occluding += 1
	verify(occluding>0,"trail view exercises real overlapping occluding tree crowns")
	var first: Image = await snapshot()
	first.save_png("res://docs/captures/world_restart/world19_trail.png")
	for tree in sample.trees: tree.visual.material_override.set_shader_parameter("fade",1.)
	for piece in sample.root_pieces: piece.node.material_override.set_shader_parameter("fade",1.)
	var opaque: Image = await snapshot()
	for i in sample.trees.size(): sample.trees[i].visual.material_override.set_shader_parameter("fade",fades[i])
	for piece in sample.root_pieces: piece.node.material_override.set_shader_parameter("fade",piece.sprite.material_override.get_shader_parameter("fade"))
	var restored: Image = await snapshot()
	var full := Rect2i(Vector2i.ZERO,first.get_size())
	verify(changed(first,opaque,full)>1000,"actual continuous crown transparency reveals the trail and actor")
	verify(changed(first,restored,full)==0,"restoring crown transparency returns the same rendered frame")
	for tree in sample.trees: tree.visual.hide()
	for piece in sample.root_pieces: piece.node.hide()
	var shadows: Image = await snapshot()
	for tree in sample.trees: tree.shadow19.hide()
	var no_shadows: Image = await snapshot()
	for tree in sample.trees: tree.shadow19.show()
	var shadows_restored: Image = await snapshot()
	verify(changed(shadows,no_shadows,full)>1000,"independent tree silhouettes still cast real ground shadows when crowns are hidden")
	verify(changed(shadows,shadows_restored,full)==0,"restoring independent tree shadows is deterministic")
	var file := FileAccess.get_file_as_string("res://docs/world19-validation.json")
	var report: Dictionary = JSON.parse_string(file)
	report.render_validation = {"checks":checks,"failures":failures,"occluding_crowns":occluding,"trail_fps":fps,"trail_draw_calls":draw_calls,"resolution":[1152,720],"renderer":"gl_compatibility"}
	var output := FileAccess.open("res://docs/world19-validation.json",FileAccess.WRITE)
	output.store_string(JSON.stringify(report,"\t"))
	print("WORLD19_RENDER ",checks," checks; failures=",failures.size()," trailFPS=",fps)
	quit(0 if failures.is_empty() else 1)
