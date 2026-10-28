extends SceneTree
var checks := 0
var failed := 0

func _initialize() -> void:
	call_deferred("_run")

func verify(condition: bool,message: String) -> void:
	checks += 1
	if condition: print("PASS ",message)
	else:
		failed += 1
		push_error(message)

func _drive(actor: CharacterBody2D,direction: Vector2,frames: int) -> void:
	for index in frames:
		await physics_frame
		actor.velocity = direction*235
		actor.move_and_slide()
	actor.velocity = Vector2.ZERO

func _run() -> void:
	var scene: Node2D = load("res://scenes/sandbox/cottage_study.tscn").instantiate()
	root.add_child(scene)
	await process_frame
	await physics_frame
	var hero: CharacterBody2D = scene.hero
	hero.frozen = true
	verify(scene.world.y_sort_enabled and scene.props.size()==4,"four independent foot-sorted environment objects")
	verify(scene.rig.projections.size()==6,"sun projections registered for four props and both characters")
	verify(hero.get_node_or_null("FootContact")!=null,"character keeps thin alpha-shaped foot contact")
	for facing in ["down","up","left","right"]:
		hero.facing = facing
		hero.moving = true
		for phase in [0.0,0.25,0.5,0.75]:
			hero.phase = phase
			hero._render_pose()
			var foot: Vector2 = hero.visual.texture.get_size()*0.5-hero.visual.offset
			verify(foot.y>0 and is_equal_approx(hero.visual.position.y,0),"stable authored foot anchor %s %.2f" % [facing,phase])
	hero.position = Vector2(1090,900)
	await _drive(hero,Vector2.UP,60)
	verify(hero.position.y>818 and hero.position.y<840,"stone footprint stops a real moving character before entering its front")
	hero.position = Vector2(180,650)
	await _drive(hero,Vector2.RIGHT,60)
	verify(hero.position.x<266 and hero.position.x>250,"tree trunk footprint blocks lateral movement")
	hero.position = Vector2(200,590)
	await _drive(hero,Vector2.RIGHT,60)
	verify(hero.position.x>350,"clear ground behind the trunk remains traversable")
	scene.rig.set_profile(scene.modes[1],true)
	await process_frame
	var sample: Dictionary = scene.rig.sample_shadow(94,155)
	verify(sample.vector.length()>40 and sample.opacity>0,"sunset keeps finite directional projections")
	scene.rig.set_profile(scene.modes[0],true)
	for index in 100: await process_frame
	verify(scene.rig.projections[0].cache_hits>0,"stationary house projection settles into cache")
	print("STUDY_PROBE ",checks-failed,"/",checks," passed")
	scene.queue_free()
	await process_frame
	quit(0 if failed==0 else 1)
