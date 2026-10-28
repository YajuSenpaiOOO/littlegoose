extends "res://scripts/ground_lab_probe.gd"

func save(name: String) -> Image:
	var frame: Image=await snapshot()
	frame.save_png("res://docs/captures/world_restart/decor42_"+name+".png")
	return frame

func run() -> void:
	var sample: Node3D=load("res://scenes/world/world42.tscn").instantiate()
	root.add_child(sample)
	while not is_instance_valid(sample.atmosphere41): await physics_frame
	while not is_instance_valid(sample.atmosphere41.decor): await physics_frame
	var art: Node3D=sample.atmosphere41
	var decor: Node3D=art.decor
	for i in 45: await physics_frame
	sample.hero.controls_enabled=false
	sample._travel_region("home")
	for i in 15: await physics_frame
	sample.label.get_parent().hide()
	verify(RenderingServer.get_current_rendering_method()=="gl_compatibility","keeps the Compatibility renderer for player hardware coverage")
	verify(decor.textures.size()==3 and decor.textures.flowers.size()==4 and decor.textures.shrubs.size()==4 and decor.textures.stones.size()==4,"twelve generated choices load from three preserved transparent atlases")
	verify(not art.flowers.visible and not art.shafts.visible and not art.focus_card.visible,"rejected flowers and hard shafts are absent; new effects default off")
	verify(decor.stones.size()==8 and decor.planted.size()>5,"road stones and sparse low undergrowth are placed")
	var first_stone: Dictionary=decor.stones[0]
	var old_height: float=first_stone.height
	for index in [1,2,3,0,2,0]: decor.choose("stones",index)
	verify(is_equal_approx(first_stone.sprite.pixel_size*float(decor.profiles.stones[0].height),old_height),"switching pebble designs preserves world scale")
	sample.process_mode=Node.PROCESS_MODE_DISABLED
	var camera_before: Transform3D=sample.camera.transform
	var views: Array[Image]=[]
	for i in 4:
		for kind in ["flowers","shrubs","stones"]: decor.choose(kind,i)
		views.append(await save("set%d"%(i+1)))
	verify(sample.camera.transform==camera_before,"all four sets use exactly the same camera")
	verify(changed(views[0],views[1],Rect2i(Vector2i.ZERO,views[0].get_size()))>1500,"candidate changes are visible at real gameplay scale")
	decor.toggle_catalog()
	await save("catalog")
	verify(decor.catalog.visible and not sample.fire_input_held(),"catalog opens and does not fire through its buttons")
	var previews_fit := true
	for kind in decor.choices:
		for button in decor.choices[kind]:
			var preview: TextureRect=button.get_child(0)
			previews_fit=previews_fit and Rect2(Vector2.ZERO,button.size).encloses(Rect2(preview.position,preview.size))
	verify(previews_fit,"all twelve atlas thumbnails fit inside their selection cards")
	decor.toggle_catalog()
	decor.choose("flowers",0); decor.choose("shrubs",1); decor.choose("stones",0)
	var clear_view: Image=await save("home")
	art.toggle_shafts()
	var soft_view: Image=await save("softlight")
	verify(changed(clear_view,soft_view,Rect2i(Vector2i.ZERO,clear_view.get_size()))>500,"soft-light option renders in Compatibility")
	art.toggle_shafts()
	art.toggle_focus()
	var focus_view: Image=await save("focus")
	verify(changed(clear_view,focus_view,Rect2i(Vector2i.ZERO,clear_view.get_size()))>500,"stronger optional depth focus renders")
	art.toggle_focus()
	# Exercise the actual passive contact path without giving stones blocking bodies.
	var home: Vector2=first_stone.home
	decor.kick_enabled=true
	sample.hero.position=Vector3(home.x, sample.floor_height(home),home.y-.22)
	sample.hero.velocity=Vector3(0,0,2.)
	decor._step_stone(first_stone,.016)
	verify(decor.kick_count==1 and first_stone.velocity.length()>.4,"walking contact kicks a loose pebble")
	sample.hero.velocity=Vector3.ZERO
	sample.hero.position.x+=2.
	for i in 130: decor._step_stone(first_stone,1./60.)
	var after := Vector2(first_stone.root.position.x,first_stone.root.position.z)
	verify(after.distance_to(home)>.15 and first_stone.lift==0. and first_stone.velocity.length()<.01,"pebble travels, lands and stops")
	verify(absf(first_stone.root.position.y-sample.floor_height(after))<.002,"kicked pebble remains grounded on the actual terrain")
	art.set_enabled(false)
	verify(not decor.visible,"F12 also hides the new decorative layer")
	art.set_enabled(true)
	sample.process_mode=Node.PROCESS_MODE_INHERIT
	sample.start_combat()
	for enemy in sample.enemies: enemy.active_ai=false
	for i in 15: await physics_frame
	verify(sample.round_index==0 and sample.enemies.size()==1,"inherited wave encounter still starts normally")
	var report := {"checks":checks,"failures":failures,"renderer":RenderingServer.get_current_rendering_method(),"choices":12,"stones":decor.stones.size()}
	var output := FileAccess.open("res://docs/decor42-validation.json",FileAccess.WRITE)
	output.store_string(JSON.stringify(report,"\t"))
	print("DECOR42 ",checks," checks; failures=",failures.size())
	quit(0 if failures.is_empty() else 1)
