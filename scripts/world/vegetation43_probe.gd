extends "res://scripts/ground_lab_probe.gd"

func save(name: String) -> Image:
	var frame: Image=await snapshot()
	frame.save_png("res://docs/captures/world_restart/vegetation43_"+name+".png")
	return frame

func run() -> void:
	var sample: Node3D=load("res://scenes/world/world43.tscn").instantiate()
	root.add_child(sample)
	while not is_instance_valid(sample.atmosphere41): await physics_frame
	while not sample.atmosphere41.grass_ready: await physics_frame
	var art: Node3D=sample.atmosphere41
	var decor: Node3D=art.decor
	for i in 40: await physics_frame
	sample.hero.controls_enabled=false
	sample._travel_region("home")
	for i in 20: await physics_frame
	sample.label.get_parent().hide()
	verify(RenderingServer.get_current_rendering_method()=="gl_compatibility","Compatibility remains the renderer")
	verify(art.focus_level==2 and art.focus_card.visible,"stronger depth focus is enabled by default")
	var varieties := {}
	for stone in decor.stones: varieties[stone.variant]=true
	verify(varieties.size()==4,"all four approved pebbles are mixed into the road")
	verify(art.tall_count>200,"existing grass instances contain coherent taller patches")
	var grass_ok := true
	for entry in art.grass_originals:
		if entry.color_after.b<.5: continue
		grass_ok=grass_ok and entry.after.basis.y.length()>entry.before.basis.y.length()*1.4
	verify(grass_ok,"tall plants actually increase mesh height, not only recolor the ground")
	var shrub_ok := true
	for plant in decor.planted: shrub_ok=shrub_ok and plant.height>=.85
	verify(shrub_ok and decor.planted.size()>4,"forest-edge shrubs have a readable taller scale")
	verify(decor.flower_batches.size()==4 and decor.flower_batches[0].multimesh.instance_count==3,"flowers are twelve independent sparse stem groups")
	sample.process_mode=Node.PROCESS_MODE_DISABLED
	var camera_before: Transform3D=sample.camera.transform
	var views: Array[Image]=[]
	for stage in 3:
		decor.set_layer_stage(stage)
		views.append(await save("layer%d"%(stage+1)))
	verify(not views.is_empty() and sample.camera.transform==camera_before,"layer comparisons use a fixed gameplay camera")
	verify(changed(views[0],views[1],Rect2i(Vector2i.ZERO,views[0].get_size()))>2000,"adding taller shrubs changes the actual scene")
	verify(changed(views[1],views[2],Rect2i(Vector2i.ZERO,views[0].get_size()))>600,"isolated flowers remain visible at gameplay scale")
	var focus_views: Array[Image]=[]
	for level in 4:
		art._set_focus_level(level)
		focus_views.append(await save("focus%d"%level))
	verify(changed(focus_views[0],focus_views[3],Rect2i(Vector2i.ZERO,focus_views[0].get_size()))>10000,"heavy focus actually softens rendered scenery")
	art._set_focus_level(2)
	var before: Dictionary=art.grass_originals[0]
	art.set_enabled(false)
	verify(before.batch.node.multimesh.get_instance_transform(before.index)==before.before,"F12 restores the original grass transform")
	art.set_enabled(true)
	verify(before.batch.node.multimesh.get_instance_transform(before.index)==before.after,"F12 restores authored tall grass without cumulative scaling")
	decor.toggle_catalog()
	await save("controls")
	verify(decor.catalog.visible,"new panel exposes layer and focus controls")
	decor.toggle_catalog()
	sample.process_mode=Node.PROCESS_MODE_INHERIT
	sample.start_combat()
	for enemy in sample.enemies: enemy.active_ai=false
	for i in 15: await physics_frame
	verify(sample.round_index==0 and sample.enemies.size()==1,"existing encounter still starts")
	verify(float(art.focus_material.get_shader_parameter("clear_span"))==7.5,"combat keeps a wider clear focal region")
	var output := FileAccess.open("res://docs/vegetation43-validation.json",FileAccess.WRITE)
	output.store_string(JSON.stringify({"checks":checks,"failures":failures,"tall_grass":art.tall_count,"shrubs":decor.planted.size(),"stone_variants":varieties.size(),"flowers":12},"\t"))
	print("VEGETATION43 ",checks," checks; failures=",failures.size())
	quit(0 if failures.is_empty() else 1)
