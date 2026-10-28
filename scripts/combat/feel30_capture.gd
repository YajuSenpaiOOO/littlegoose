extends "res://scripts/ground_lab_probe.gd"
func run() -> void:
	var sample: Node3D=load("res://scenes/world/world30.tscn").instantiate()
	root.add_child(sample)
	while not sample.feel_ready: await physics_frame
	sample.start_combat()
	sample.set_cup_phone(false)
	for enemy in sample.enemies: enemy.active_ai=false
	for i in 30: await physics_frame
	sample.hero.facing="left"
	sample.hero.request_dash(Vector2.LEFT)
	for i in 2: await physics_frame
	var dash: Image=await snapshot()
	dash.save_png("res://docs/captures/world_restart/feel30_dash.png")
	verify(sample.hero.dash_left>0. and sample.hero.ghosts.size()>0,"authored dash and afterimages render during real physics movement")
	for i in 20: await physics_frame
	sample.hero.controls_enabled=false
	for enemy in sample.enemies: enemy.receive_hit(99.,Vector3(1,0,-1).normalized())
	await create_timer(.55,true,false,true).timeout
	var slow: Image=await snapshot()
	slow.save_png("res://docs/captures/world_restart/feel30_closeup.png")
	verify(Engine.time_scale==.25 and sample.camera_gain>1.2,"actual GPU closeup runs during the delayed 0.25x slow motion")
	await create_timer(.7,true,false,true).timeout
	# A lying corpse must be aimable at its actual low height, not the old .85m plane.
	var corpse: CharacterBody3D=sample.enemies[2]
	var pixel: Vector2=sample.camera.unproject_position(corpse.position+Vector3.UP*.3)
	var target: Vector3=sample.aim_at_screen(pixel)
	verify(target.y-corpse.position.y<.75,"mouse pointing at a corpse aims at its low 3D body")
	var before: int=corpse.whip_count
	sample.fire_at(target)
	for i in 150:
		await physics_frame
		if corpse.whip_count>before: break
	verify(corpse.whip_count>before,"actual cursor-targeted bullet can strike the corpse after closeup")
	sample.start_combat()
	sample.set_cup_phone(false)
	sample.hero.controls_enabled=false
	for enemy in sample.enemies: enemy.active_ai=false
	for i in 15: await physics_frame
	sample.hero.dash_direction=Vector2.LEFT
	sample.perfect_dodge()
	await create_timer(.12,true,false,true).timeout
	var butterfly: Image=await snapshot()
	butterfly.save_png("res://docs/captures/world_restart/feel30_butterfly.png")
	var art: Array=get_nodes_in_group("perfect_dodge_art")
	verify(art.size()==1 and art[0].pieces[0].modulate.a>.5 and art[0].pieces[0].is_visible_in_tree(),"original animated butterflies render through the projected world anchor")
	sample._reset_impact_state()
	sample.invulnerability=0.
	sample.hurt_player(20.,Vector2(sample.hero.position.x-1.,sample.hero.position.z))
	sample.hero.render_pose()
	var hurt: Image=await snapshot()
	hurt.save_png("res://docs/captures/world_restart/feel30_hurt.png")
	verify(sample.hero.visual.texture!=load("res://assets/hero_pixel/ko_knocked_v2.png"),"rendered nonlethal hurt retains normal character art")
	print("FEEL30_CAPTURE ",checks," checks; failures=",failures.size())
	quit(0 if failures.is_empty() else 1)
