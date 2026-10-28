extends "res://scripts/ground_lab_probe.gd"
func run() -> void:
	var sample: Node3D = load("res://scenes/world/world26.tscn").instantiate()
	root.add_child(sample)
	while not is_instance_valid(sample.trail_batch): await physics_frame
	sample.start_combat()
	sample.hero.controls_enabled = false
	for enemy in sample.enemies: enemy.set_physics_process(false)
	for i in 3: await physics_frame
	var enemy: CharacterBody3D = sample.enemies[0]
	enemy.hp = 1000.
	for strike in 12:
		enemy.hit_rearm = 0.
		enemy.receive_hit(1.,Vector3(-1,0,-1).normalized())
		for frame in 8:
			enemy.hit_left = maxf(0.,.12-float(frame)/60.)
			enemy._render_legacy(.5)
	var offset := Vector2(enemy.visual.position.x,enemy.visual.position.z).length()
	print("ALIGN27_AFTER_12_HITS offset_m=",offset," local_visual=",enemy.visual.position," hit_body=",enemy.hit_area.position)
	verify(offset<=2./sample.Profile.PPM+.001,"repeated recoil stays inside one authored kick rather than accumulating")
	enemy.hit_left=0.; enemy.hopping=false; enemy.landing_left=0.
	enemy._render_legacy(0.)
	verify(Vector2(enemy.visual.position.x,enemy.visual.position.z).length()<.0001,"neutral pose returns to the gameplay root after hits")
	for direction in [Vector3.RIGHT,Vector3.LEFT,Vector3.FORWARD,Vector3.BACK]:
		enemy.hit_direction = direction
		enemy.hit_left = .06
		for frame in 180:
			enemy.position += Vector3(.003,0,-.002)
			enemy._render_legacy(sin(float(frame)/180.*PI)*sample.Profile.HOP_LIFT)
		var drift := Vector2(enemy.visual.position.x,enemy.visual.position.z).length()
		verify(drift<=2./sample.Profile.PPM+.001,"moving/hopping recoil stays bounded in direction "+str(direction))
		enemy.hit_left=0.; enemy._render_legacy(0.)
		verify(enemy.visual.position.length()<.0001,"landing removes all temporary recoil in direction "+str(direction))
		enemy.reset_physics_interpolation()
		await physics_frame
	print("ALIGN27 ",checks," checks; failures=",failures.size())
	quit(0 if failures.is_empty() else 1)
