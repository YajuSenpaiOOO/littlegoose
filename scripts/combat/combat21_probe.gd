extends "res://scripts/world/world19_probe.gd"

func freeze(enemy: CharacterBody3D) -> void:
	enemy.active_ai = false
	enemy.hopping = false
	enemy.rest = 999.
	enemy.impulse = Vector2.ZERO

func place(sample: Node3D,enemy: CharacterBody3D,at: Vector2) -> void:
	enemy.position = Vector3(at.x,sample.meadow.walk_height(at,true)+.04,at.y)
	enemy.velocity = Vector3.ZERO
	enemy.reset_physics_interpolation()

func scene_path() -> String:
	return "res://scenes/world/world21.tscn"

func report_path() -> String:
	return "res://docs/combat21-validation.json"

func run() -> void:
	var sample: Node3D = load(scene_path()).instantiate()
	root.add_child(sample)
	for i in 120:
		await physics_frame
		if sample.combat_ready: break
	verify(sample.combat_ready,"combat scene initializes native physics navigation")
	verify(not sample.meadow.terrace_enabled and sample.stairs_mesh==null,"isolated arena and stairs are absent")
	var center: Vector2 = sample.meadow.landmarks.grove
	var original = load("res://scripts/world/world_surface19.gd").new()
	verify(is_equal_approx(sample.meadow.height_at(center.x,center.y,true),original.height_at(center.x,center.y,true)),"grove center returns to original ground height")
	verify(sample.meadow.named_routes.size()==6 and sample.house_fits[0].height>6.,"ring landmark and enlarged house remain")
	verify(sample.combat_textures.size()==6,"six original tuantuan motion poses are loaded")
	var entrance := center+Vector2(8,0)
	sample._teleport15(entrance)
	for i in 5: await physics_frame
	verify(sample.wave_state=="fighting" and Vector2(sample.hero.position.x,sample.hero.position.z).distance_to(entrance)<.25,"walking into the grove starts combat without teleporting player")
	for enemy in sample.enemies: freeze(enemy)
	sample.wave_state = "cleared"
	for route in sample.meadow.named_routes:
		if route.name=="junction_to_grove": await walk_route(sample,route)
	sample.start_combat()
	sample.hero.controls_enabled = false
	verify(sample.enemies.size()==6 and sample.player_hp==100.,"restart creates six enemies and full player health")
	for enemy in sample.enemies: freeze(enemy)
	var victim: CharacterBody3D = sample.enemies[0]
	place(sample,victim,center)
	sample._teleport15(center+Vector2(0,4))
	for i in 8: await physics_frame
	var target := victim.position+Vector3.UP*.58
	var aimed: Vector3 = sample.aim_at_screen(sample.camera.unproject_position(target))
	verify(aimed.is_finite() and aimed.distance_to(target)<1.,"screen aim finds actual enemy hit volume at perspective angle")
	var before: Vector3 = victim.position
	sample.fire_at(target)
	for i in 25: await physics_frame
	verify(victim.hp==8. and sample.landed_hits==1,"swept native projectile deals exactly one hit")
	verify(victim.position.distance_to(before)>.1,"projectile produces real ground knockback")
	for shot in 2:
		sample.fire_at(victim.position+Vector3.UP*.58)
		for i in 25: await physics_frame
	verify(victim.dead and sample.defeated_count==1,"three projectiles defeat an ordinary tuantuan")
	verify(victim.hit_area.collision_layer==0,"defeated enemy stops intercepting projectiles")
	var tree_center := Vector2.ZERO
	var found := false
	for tree in sample.trees:
		var at := Vector2(tree.root.position.x,tree.root.position.z)
		var diff: Vector2 = at-center
		if absf(diff.x)>17. or absf(diff.y)>12. or diff.length()<10.: continue
		for child in tree.root.get_children():
			if child is StaticBody3D:
				var point: Vector3 = child.get_child(0).global_position
				tree_center = Vector2(point.x,point.z)
				found = true
		if found: break
	verify(found,"test locates an actual forest trunk in navigation bounds")
	var blocked: CharacterBody3D = sample.enemies[1]
	place(sample,blocked,tree_center-Vector2(0,3))
	sample._teleport15(tree_center+Vector2(0,3))
	sample.invulnerability = 999.
	for i in 8: await physics_frame
	var old_blocks: int = sample.blocks
	sample.fire_at(blocked.position+Vector3.UP*.58)
	for i in 30: await physics_frame
	verify(sample.blocks>old_blocks and blocked.hp==12.,"tree trunk blocks a real projectile before the enemy")
	var path: PackedVector2Array = sample.navigation.path(tree_center-Vector2(0,3),tree_center+Vector2(0,3))
	verify(path.size()>3,"navigation finds a route around real tree collision")
	blocked.active_ai = true
	blocked.rest = 0.
	for i in 300: await physics_frame
	var remaining := Vector2(blocked.position.x,blocked.position.z).distance_to(Vector2(sample.hero.position.x,sample.hero.position.z))
	verify(remaining<1.7,"hopping enemy physically routes around a trunk to the player")
	verify(blocked.is_on_floor(),"enemy visual hops keep native collision grounded")
	freeze(blocked)
	sample._teleport15(center+Vector2(0,4))
	place(sample,blocked,center+Vector2(0,4.6))
	sample.invulnerability = 0.
	for i in 3: await physics_frame
	verify(sample.player_hp==90. and sample.hurt_count==1,"physical enemy contact damages player once")
	sample.hurt_player(10.,center)
	verify(sample.player_hp==90.,"invulnerability prevents stacked contact damage")
	var hero_before: Vector3 = sample.hero.position
	for i in 24: await physics_frame
	verify(sample.hero.position.distance_to(hero_before)>.2,"player knockback moves the native capsule on ground")
	sample.invulnerability = 0.
	sample.hurt_player(100.,center)
	verify(sample.wave_state=="defeated" and not sample.hero.controls_enabled and sample.shots.is_empty(),"defeat stops movement and clears projectiles")
	sample._unhandled_input(event(KEY_F5))
	for i in 5: await physics_frame
	verify(sample.enemies.size()==6 and sample.player_hp==100. and sample.hero.controls_enabled,"F5 fully resets the trial after defeat")
	sample._unhandled_input(event(KEY_F7))
	var first: Vector3 = sample.enemies[0].position
	var fired: int = sample.fired_count
	sample.fire_at(sample.enemies[0].position+Vector3.UP*.6)
	for i in 15: await physics_frame
	verify(sample.enemies[0].position==first and sample.fired_count==fired,"pause freezes enemies and blocks shooting")
	sample._unhandled_input(event(KEY_F7))
	for enemy in sample.enemies: enemy.receive_hit(12.,Vector3.RIGHT)
	verify(sample.wave_state=="cleared" and sample.defeated_count==6,"clearing the six-enemy trial reports completion")
	report.checks = checks
	report.failures = failures
	report.tree_chase_remaining_metres = remaining
	FileAccess.open(report_path(),FileAccess.WRITE).store_string(JSON.stringify(report,"\t"))
	print("COMBAT21_PROBE ",checks," checks; failures=",failures.size())
	quit(0 if failures.is_empty() else 1)
