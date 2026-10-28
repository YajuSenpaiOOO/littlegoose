extends "res://scripts/ground_lab_probe.gd"
class Actor:
	extends "res://scripts/combat/hero30.gd"
	var test_direction := Vector2.ZERO
	func movement_input() -> Vector2: return test_direction if controls_enabled else Vector2.ZERO
	func dash_key_down() -> bool: return false
class Sample:
	extends "res://scripts/world/world33.gd"
	var scripted_fire := false
	func _hero_script() -> Script: return Actor
	func fire_at(target: Vector3) -> void:
		if scripted_fire: super.fire_at(target)

func run() -> void:
	var sample: Node3D=Sample.new()
	root.add_child(sample)
	while not sample.encounter_ready: await physics_frame
	sample.set_process_unhandled_input(false)
	sample.start_combat(); sample.set_cup_phone(false)
	var deadline := Time.get_ticks_msec()+35000
	var started := Time.get_ticks_msec()
	var next_fire := 2.
	var total_attacks := 0
	var seen: Dictionary={}
	var captured_warning := false
	var captured_attack := false
	var peak_bits := 0
	while Time.get_ticks_msec()<deadline and sample.wave_state=="fighting":
		var elapsed := (Time.get_ticks_msec()-started)/1000.
		var at := Vector2(sample.hero.position.x,sample.hero.position.z)
		var goal: Vector2=sample.meadow.landmarks.grove+Vector2(cos(elapsed*.65),sin(elapsed*.65))*4.
		sample.hero.test_direction=(goal-at).normalized()
		var closest: CharacterBody3D
		var best := INF
		for enemy in sample.enemies:
			if not is_instance_valid(enemy): continue
			seen[enemy.get_instance_id()]=enemy.attacks_started
			if enemy.dead: continue
			var distance: float=enemy.global_position.distance_to(sample.hero.global_position)
			if distance<best: best=distance; closest=enemy
			if enemy.attack_phase=="lunge" and distance<2.5 and sample.hero.dash_cd<=0.:
				sample.hero.request_dash(sample.hero.test_direction)
			if enemy.attack_phase=="windup" and enemy.phase_clock>.24 and not captured_warning:
				var image: Image=await snapshot()
				image.save_png("res://docs/captures/world_restart/encounter33_live_windup.png")
				captured_warning=true
			if enemy.attack_phase=="lunge" and enemy.phase_clock>.08 and not captured_attack:
				var image: Image=await snapshot()
				image.save_png("res://docs/captures/world_restart/encounter33_live_lunge.png")
				captured_attack=true
		if closest!=null and elapsed>=next_fire:
			next_fire=elapsed+.14
			var target: Vector3=closest.global_position+Vector3.UP*.8
			# Automated player predicts briefly; no extra aim assistance is added to gameplay.
			target+=Vector3(closest.velocity.x,0,closest.velocity.z)*minf(.18,best/sample.projectile_speed())
			sample.scripted_fire=true; sample.fire_at(target); sample.scripted_fire=false
		peak_bits=maxi(peak_bits,sample.jelly_fx.bits.size())
		await physics_frame
	for value: int in seen.values(): total_attacks+=value
	verify(sample.wave_state=="cleared" and sample.defeated_count==3,"full three-enemy trial can be cleared using only native projectiles and normal dash")
	verify(sample.player_hp>0. and total_attacks>0,"attacks really occur and the moving test player can survive the encounter")
	verify(captured_warning and captured_attack,"windup and airborne lunge are captured from real running combat")
	verify(peak_bits>0 and peak_bits<=sample.jelly_fx.MAX_BITS,"painted fragments remain visible and bounded throughout continuous fighting")
	sample.hero.test_direction=Vector2.ZERO
	sample.status_next=0; sample._status()
	var end: Image=await snapshot()
	end.save_png("res://docs/captures/world_restart/encounter33_clear.png")
	print("ENCOUNTER33_CAPTURE ",checks," checks; failures=",failures.size()," hp=",sample.player_hp," shots=",sample.fired_count," hits=",sample.landed_hits," attacks=",total_attacks," peak_bits=",peak_bits)
	sample.queue_free(); await process_frame
	quit(0 if failures.is_empty() else 1)
