extends SceneTree
var checks := 0
var failures := 0

func _initialize() -> void: call_deferred("_run")

func verify(value: bool,message: String) -> void:
	checks += 1
	if value: print("PASS ",message)
	else:
		failures += 1
		push_error(message)

func _drive(actor: CharacterBody2D,direction: Vector2,frames: int) -> void:
	for i in frames:
		await physics_frame
		actor.velocity = direction*78.3
		actor.move_and_slide()
	actor.velocity = Vector2.ZERO

func _run() -> void:
	var scene: Node2D = load("res://scenes/sandbox/home_pixel_study.tscn").instantiate()
	root.add_child(scene)
	await process_frame
	await process_frame
	var hero: CharacterBody2D = scene.hero
	hero.frozen = true
	verify(scene.trees.size()==19 and scene.world.y_sort_enabled,"nineteen separately sorted trees form the grove")
	var solid_count := 0
	for prop in scene.world.get_children():
		if prop.get("profile") and prop.profile.projection_kind!=2: solid_count += 1
	verify(scene.registered_props.size()==solid_count and solid_count>27,"old and new solid props register independently")
	verify(scene.local_sources.size()==2 and scene.emitters.size()==2,"two authored lamps share their real light positions")
	verify(scene.rig.projections.size()==solid_count+2,"props and both characters receive solar projections")
	verify(scene.nature.sources.size()==19,"leaf sources come from the actual tree positions")
	verify(hero.get_node_or_null("FootContact")!=null,"hero keeps alpha-shaped shoe contact")
	verify(is_equal_approx(hero.target_height*scene.camera.zoom.x,93.9),"actor screen scale remains consistent with prior prototype")
	hero.position = Vector2(25,65)
	await _drive(hero,Vector2.UP,70)
	verify(hero.position.y>-4 and hero.position.y<1,"real collision stops the hero at the cottage front")
	var bench: Node2D = scene.world.get_node("GardenBench")
	hero.position = bench.position+Vector2(0,40)
	await _drive(hero,Vector2.UP,50)
	var expected_bench_y: float = bench.get_node("Footprint").global_position.y+bench.effective_footprint().y*bench.size_factor*0.5+14.0/3.0+2.0
	verify(absf(hero.position.y-expected_bench_y)<2,"bench footprint blocks walking through the seat at its new resting nook")
	var stone: Node2D = scene.world.get_node("EdgeStoneRight")
	hero.position = stone.position+Vector2(0,40)
	await _drive(hero,Vector2.UP,50)
	var expected_stone_y: float = stone.get_node("Footprint").global_position.y+stone.effective_footprint().y*stone.size_factor*0.5+14.0/3.0+2.0
	verify(absf(hero.position.y-expected_stone_y)<2,"stone collision reaches its visible base after repositioning")
	hero.position = Vector2(27,174)
	await _drive(hero,Vector2.UP,65)
	verify(hero.position.y<94 and hero.position.y>83,"the main entrance path stays passable")
	var bed: Node2D = scene.world.get_node("CabbageBed")
	hero.position = bed.position+Vector2(-45,-20)
	await _drive(hero,Vector2.RIGHT,35)
	verify(hero.position.x<bed.position.x-29 and hero.position.x>bed.position.x-34,"vegetable bed has a real footprint while its dirt edge remains decorative")
	var tab := InputEventKey.new()
	tab.pressed = true
	tab.physical_keycode = KEY_TAB
	scene._unhandled_key_input(tab)
	verify(scene.overview and is_equal_approx(scene.camera.zoom.x,2.1),"overview can show the courtyard and outer lane together")
	scene.rig.set_profile(load("res://assets/world_lighting_v1/night.tres"),true)
	scene._update_lamps()
	verify(scene.emitters[0].ground_light.energy>0.7 and scene.rig.current_opacity==0,"night turns on lamps while removing sunlight shadows")
	scene.rig.set_profile(load("res://assets/world_lighting_v1/noon.tres"),true)
	scene._update_lamps()
	verify(scene.emitters[0].ground_light.energy<0.3 and scene.rig.current_opacity>0,"daylight restores sun shadows and lowers lamp energy")
	for i in 12: await process_frame
	var cottage: Node2D = scene.world.get_node("Cottage")
	verify(cottage.solar.cache_hits>0,"static cottage shadow uses the existing cache")
	print("PIXEL_HOME_PROBE ",checks-failures,"/",checks," passed")
	scene.queue_free()
	await process_frame
	quit(0 if failures==0 else 1)
