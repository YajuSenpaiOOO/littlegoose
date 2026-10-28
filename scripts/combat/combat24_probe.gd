extends "res://scripts/ground_lab_probe.gd"
func run() -> void:
	var sample: Node3D = load("res://scenes/world/world24.tscn").instantiate()
	root.add_child(sample)
	while not is_instance_valid(sample.fx_layer): await physics_frame
	sample.start_combat()
	sample.hero.controls_enabled = false
	for enemy in sample.enemies:
		enemy.set_physics_process(false)
		enemy.velocity = Vector3.ZERO
	verify(sample.enemies.size()==3 and sample.total_enemies==3,"old first-wave count is three ordinary enemies")
	verify(is_equal_approx(sample.attack_cooldown(),.14) and sample.projectile_damage()==1.,"old base volley restores 0.14s cadence and 1 damage")
	verify(absf(sample.projectile_speed()/4.1-213./78.3)<.0001,"projectile speed preserves the old projectile/player ratio")
	verify(sample.hero.legacy_motion_enabled,"hero uses old acceleration, release and knockback decay")
	var victim: CharacterBody3D = sample.enemies[0]
	var center: Vector2 = sample.meadow.landmarks.grove
	victim.position = Vector3(center.x,sample.meadow.walk_height(center,true)+.04,center.y+1.)
	for i in 4: await physics_frame
	var start: Vector3 = sample.projectile_origin()
	sample.weapon_rng.seed = 24
	sample.fire_at(victim.position+Vector3.UP*.8)
	verify(sample.shots.size()==1 and sample.shots[0].node.mesh==null and sample.shots[0].has("art"),"real projectile is rendered by the old pearl art adapter")
	verify(is_equal_approx(sample.shots[0].life,1.4),"old bullet life and range are restored")
	verify(sample.shots[0].node.position.distance_to(start)>.2,"old five-pixel muzzle clearance is restored")
	for i in 90:
		await physics_frame
		if sample.landed_hits>0: break
	verify(victim.hp==11. and sample.landed_hits==1,"actual native 3D pearl hit deals old base damage")
	verify(absf(victim.impulse.length()-sample.Profile.KNOCK)<.001,"old 110px knock impulse is converted consistently")
	verify(victim.hit_left>0. and victim.impact_pause==0.,"authored old hit pose replaces generic per-enemy 55ms freeze")
	verify(sample.combo==1 and sample.feedback_count==1,"successful impact advances combo once")
	victim.receive_hit(1.,Vector3.RIGHT)
	var expected: Vector2 = (Vector2(victim.hit_direction.x,victim.hit_direction.z)*sample.Profile.KNOCK)
	verify(victim.impulse.length()<=sample.Profile.KNOCK_MAX+.001,"repeated knock combines with damping and obeys the old cap")
	# Reset the fixture's HP so the following sequence proves the twelve-hit lifecycle.
	victim.hp=12.; victim.hit_count=0; victim.impulse=Vector2.ZERO
	var old_hits: int = sample.landed_hits
	for shot in 12:
		sample.fire_at(victim.position+Vector3.UP*.8)
		for i in 90:
			await physics_frame
			if sample.landed_hits>old_hits+shot: break
	verify(victim.dead and sample.defeated_count==1,"twelve real 1-damage projectiles complete the old kill cycle")
	verify(victim.hit_area.collision_layer==8 and victim.corpse_time==0.,"defeated body remains hittable rather than vanishing immediately")
	var whip_before: int = victim.whip_count
	sample.fire_at(victim.position+Vector3.UP*.35)
	for i in 90:
		await physics_frame
		if victim.whip_count>whip_before: break
	verify(victim.whip_count==whip_before+1,"a real follow-up projectile gives the corpse a harmless recoil")
	victim._physics_process(.15)
	verify(victim.visual.position.y>0.,"old defeat sequence arcs through the air before landing")
	victim._physics_process(.15)
	verify(absf(victim.visual.position.y)<.02,"defeat arc lands after about 0.28s")
	verify(sample.anchors.size()<=144,"legacy cosmetic anchors obey a bounded budget")
	sample._reset_impact_state()
	sample.hitstop(.012)
	var until: float = sample.stop_until
	sample.hitstop(.012)
	verify(sample.stop_until==until,"ordinary repeated hitstop is throttled by the old real-time gate")
	sample.hitstop(.04,true)
	verify(sample.stop_until>until and Engine.time_scale==.05,"a longer forced event can override the short stop")
	var deadline := Time.get_ticks_msec()+600
	while Engine.time_scale<1. and Time.get_ticks_msec()<deadline: await process_frame
	verify(Engine.time_scale==1.,"global hitstop always recovers using real time")
	sample._reset_impact_state()
	sample.combo=9
	sample.notify_hit()
	verify(sample.combo==10 and is_equal_approx(sample.stop_duration,.045) and sample.trauma>=.3,"old tenth-hit milestone gets its separate stronger beat")
	for i in 3: sample.notify_miss()
	verify(sample.combo==0,"three misses break the old combo")
	sample._reset_impact_state()
	sample.invulnerability=0.
	sample.combo=5
	sample.hurt_player(20.,Vector2(sample.hero.position.x-1.,sample.hero.position.z))
	verify(sample.player_hp==80. and sample.combo==0 and is_equal_approx(sample.invulnerability,.8),"old hurt gate and combo break adapt to the normalized health bar")
	verify(absf(sample.hero.combat_impulse.length()-90./sample.Profile.PPM)<.001,"player hurt restores the old knockback magnitude")
	sample._unhandled_input(event(KEY_F7))
	verify(Engine.time_scale==1. and sample.combat_paused,"debug pause clears any pending global slowdown")
	sample._unhandled_input(event(KEY_F12))
	verify(not sample.legacy_feel and sample.enemies.size()==6 and sample.projectile_damage()==4.,"F12 resets into the complete prior trial chain for comparison")
	sample._unhandled_input(event(KEY_F12))
	verify(sample.legacy_feel and sample.enemies.size()==3 and sample.player_hp==100. and Engine.time_scale==1.,"F12 restores old chain with a clean round and clock")
	sample.hitstop(.04,true)
	sample.queue_free()
	await process_frame
	await create_timer(.06,true,false,true).timeout
	verify(Engine.time_scale==1.,"leaving the scene restores global time")
	FileAccess.open("res://docs/combat24-validation.json",FileAccess.WRITE).store_string(JSON.stringify({"checks":checks,"failures":failures},"\t"))
	print("COMBAT24_PROBE ",checks," checks; failures=",failures.size())
	quit(0 if failures.is_empty() else 1)
