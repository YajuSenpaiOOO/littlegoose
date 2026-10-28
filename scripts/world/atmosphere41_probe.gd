extends "res://scripts/ground_lab_probe.gd"

func distinct(a: Image,b: Image,threshold := .035) -> int:
	var count := 0
	for y in a.get_height():
		for x in a.get_width():
			var p := a.get_pixel(x,y)
			var q := b.get_pixel(x,y)
			if maxf(absf(p.r-q.r),maxf(absf(p.g-q.g),absf(p.b-q.b)))>threshold: count+=1
	return count

func run() -> void:
	var sample: Node3D=load("res://scenes/world/world41.tscn").instantiate()
	root.add_child(sample)
	while not is_instance_valid(sample.atmosphere41): await physics_frame
	for i in 30: await physics_frame
	var art: Node3D=sample.atmosphere41
	sample.hero.controls_enabled=false
	sample._travel_region("home")
	for i in 20: await physics_frame
	verify(is_equal_approx(sample.camera.rotation_degrees.x,-25.) and is_equal_approx(sample.camera.fov,42.),"approved 25 degree perspective and exploration camera are preserved")
	verify(art.flowers.multimesh.instance_count>25,"authored low flowers are batched rather than individual draw calls")
	verify(art.frame_trees.size()==2,"two fitted foreground trees frame the courtyard")
	verify(not art.focus_card.visible,"depth focus defaults off")
	# Freeze gameplay and the clock uniforms, so wind and breathing cannot
	# produce false positive image differences.
	sample.process_mode=Node.PROCESS_MODE_DISABLED
	var baseline: Image=await snapshot()
	baseline.save_png("res://docs/captures/world_restart/atmosphere41_home.png")
	art.toggle_focus()
	var focused: Image=await snapshot()
	focused.save_png("res://docs/captures/world_restart/atmosphere41_focus.png")
	verify(distinct(baseline,focused, .015)>500,"optional focus changes rendered pixels")
	art.toggle_focus()
	art.toggle_shafts()
	var no_shafts: Image=await snapshot()
	no_shafts.save_png("res://docs/captures/world_restart/atmosphere41_no_shafts.png")
	art.toggle_shafts()
	var shafts: Image=await snapshot()
	shafts.save_png("res://docs/captures/world_restart/atmosphere41_shafts.png")
	var shaft_pixels := distinct(no_shafts,shafts)
	print("SHAFT_PIXELS ",shaft_pixels)
	verify(shaft_pixels>150,"world-space sun shafts are visible in actual courtyard rendering")
	art.set_enabled(false)
	verify(not art.flowers.visible and not art.shafts.visible and not art.focus_card.visible,"F12 removes optional atmosphere passes")
	verify(art.environment.fog_mode==art.original_environment.fog_mode and art.environment.ambient_light_energy==art.original_environment.ambient_light_energy,"comparison restores original environment settings")
	art.set_enabled(true)
	verify(art.flowers.visible and art.shafts.visible,"comparison restores the authored accents")
	var roots_ok := true
	for i in art.flowers.multimesh.instance_count:
		var at: Vector3=art.flowers.multimesh.get_instance_transform(i).origin
		roots_ok=roots_ok and absf(at.y-sample.floor_height(Vector2(at.x,at.z)))<.08 and sample.meadow.route_distance(Vector2(at.x,at.z))>=.91
	verify(roots_ok,"flower roots follow the actual floor while keeping the path centre clear")
	sample.process_mode=Node.PROCESS_MODE_INHERIT
	for i in 100: await process_frame
	print("SCENERY41 flowers=",art.flowers.multimesh.instance_count,"; use atmosphere41_performance.gd for timing without screenshot-comparison CPU stalls")
	sample.start_combat()
	for enemy in sample.enemies: enemy.active_ai=false
	for i in 15: await physics_frame
	verify(sample.round_index==0 and sample.total_enemies==6 and sample.enemies.size()==1,"scenery still enters the inherited one/two/three enemy encounter")
	var frame: Image=await snapshot()
	frame.save_png("res://docs/captures/world_restart/atmosphere41_combat.png")
	var output := FileAccess.open("res://docs/atmosphere41-validation.json",FileAccess.WRITE)
	output.store_string(JSON.stringify({"checks":checks,"failures":failures,"shaft_changed_pixels":shaft_pixels,"renderer":"gl_compatibility","resolution":root.get_visible_rect().size,"flower_count":art.flowers.multimesh.instance_count},"\t"))
	print("ATMOSPHERE41 ",checks," checks; failures=",failures.size())
	quit(0 if failures.is_empty() else 1)
