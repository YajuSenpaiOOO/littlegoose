extends "res://scripts/ground_lab_probe.gd"
class Actor:
	extends "res://scripts/combat/hero36.gd"
	var test_direction := Vector2.ZERO
	func movement_input() -> Vector2: return test_direction
	func dash_key_down() -> bool: return false
	func parry_key_down() -> bool: return false
class Sample:
	extends "res://scripts/world/world37.gd"
	var scripted_fire := false
	func _hero_script() -> Script: return Actor
	func fire_at(target: Vector3) -> void:
		if scripted_fire: super.fire_at(target)

func alive(sample: Node3D) -> Array[CharacterBody3D]:
	var found: Array[CharacterBody3D]=[]
	for enemy in sample.enemies:
		if is_instance_valid(enemy) and not enemy.dead: found.append(enemy)
	return found

func capture(name: String) -> void:
	var shot: Image=await snapshot()
	shot.save_png("res://docs/captures/world_restart/encounter37_"+name+".png")

func check_pressure(sample: Node3D) -> void:
	var actors := alive(sample)
	verify(actors.size()==sample.round_index+1,"round %d introduces %d living enemies"%[sample.round_index+1,sample.round_index+1])
	if actors.size()<2: return
	for actor in actors: actor.attack_phase="approach"
	sample.next_attack33=0.
	verify(sample.reserve_attack(actors[0]),"round opens an attack slot")
	actors[0].attack_phase="windup"; sample.next_attack33=0.
	if actors.size()==2:
		verify(not sample.reserve_attack(actors[1]),"two-enemy round allows only one attacker at a time")
	else:
		verify(sample.reserve_attack(actors[1]),"final round allows a second staggered attack")
		actors[1].attack_phase="windup"; sample.next_attack33=0.
		verify(not sample.reserve_attack(actors[2]),"final round never starts three simultaneous attacks")
	for actor in actors: actor.attack_phase="approach"
	sample.last_attacker=null; sample.next_attack33=sample.combat_clock33+.8

func run() -> void:
	var sample: Node3D=Sample.new()
	root.add_child(sample)
	while not sample.encounter37_ready: await physics_frame
	sample.set_process_unhandled_input(false)
	sample.start_combat(); sample.set_cup_phone(false)
	sample.weapon_rng.seed=370037
	verify(sample.total_enemies==6 and sample.enemies.size()==1 and sample.round_index==0,"a fresh encounter begins with one of six total enemies")
	verify(not sample.health_track.visible and not sample.battle_label.visible and not sample.cup_chip.visible,"new HUD replaces the old trial text and health display")
	verify(sample.encounter_hud.gems.gem_count==5 and sample.encounter_hud.gems.target==100.,"five original painted gems represent the existing 100 HP")
	sample.player_hp=80.; sample.invulnerability=999.
	# Native projectiles, hit reactions, terrain collision and world tick all run.
	# Disable AI only for the shooting/round-lifecycle fixture; separate probes
	# cover live parry and the moving attack timings without this fixture.
	var observed_round := -1
	var pause_checked := false
	var fire_clock := 0.
	var deadline := Time.get_ticks_msec()+65000
	while sample.wave_state=="fighting" and Time.get_ticks_msec()<deadline:
		for enemy in alive(sample): enemy.active_ai=false
		if observed_round!=sample.round_index:
			observed_round=sample.round_index
			check_pressure(sample)
			verify(sample.player_hp==80.,"round changes preserve remaining HP")
			await capture("round%d"%(observed_round+1))
		if sample.between_left>0. and not pause_checked:
			pause_checked=true
			sample.hero.test_direction=Vector2.ZERO
			sample.parry_count=2; sample.perfect_dodges=1
			sample.hero.dash_cd=.3; sample.hero.parry_cd=.6
			sample._unhandled_input(event(KEY_F7))
			var gap: float=sample.between_left
			await create_timer(.25,true,false,true).timeout
			verify(sample.combat_paused and sample.between_left==gap and sample.hero.parry_cd==.6,"pause freezes the inter-round timer and action cooldowns")
			verify(sample.parry_count==2 and sample.perfect_dodges==1,"pause preserves success counters instead of resetting combat feedback state")
			verify(sample.closeup_started<0. and sample.wave_state=="fighting","intermediate kills do not play the final-enemy closeup")
			var shots_before: int=sample.fired_count
			sample.scripted_fire=true; sample.fire_at(sample.hero.position+Vector3.FORWARD*3.); sample.scripted_fire=false
			verify(sample.fired_count==shots_before,"paused and inter-round input cannot fire stray projectiles")
			sample._unhandled_input(event(KEY_F7))
			sample.parry_count=0; sample.perfect_dodges=0; sample.hero.reset_actions()
			await capture("breather")
		var targets := alive(sample)
		if not targets.is_empty() and sample.between_left<=0.:
			var enemy: CharacterBody3D=targets[0]
			var toward := Vector2(enemy.position.x-sample.hero.position.x,enemy.position.z-sample.hero.position.z)
			sample.hero.test_direction=toward.normalized() if toward.length()>4. else Vector2.ZERO
			fire_clock+=sample.get_physics_process_delta_time()
			if fire_clock>=sample.attack_cooldown():
				fire_clock=0.; sample.scripted_fire=true
				sample.fire_at(enemy.position+Vector3.UP*.70)
				sample.scripted_fire=false
		else: sample.hero.test_direction=Vector2.ZERO
		await physics_frame
	sample.hero.test_direction=Vector2.ZERO
	verify(sample.wave_state=="cleared" and sample.defeated_count==6 and observed_round==2,"real goose projectiles can complete all three rounds and six defeats")
	verify(sample.landed_hits>=72 and sample.fired_count>=72,"round progression came from native projectile damage, not scripted enemy removal")
	verify(sample.player_hp==80.,"finishing never silently heals the player")
	var end_deadline := Time.get_ticks_msec()+2500
	while not sample.result_open and Time.get_ticks_msec()<end_deadline: await process_frame
	verify(sample.result_open and sample.encounter_hud.result.visible and not sample.hero.controls_enabled,"victory presents a readable result card after the last-kill camera beat")
	await capture("victory")
	var fired_before: int=sample.fired_count
	sample.scripted_fire=true; sample.fire_at(sample.hero.position+Vector3.FORWARD*3.); sample.scripted_fire=false
	verify(sample.fired_count==fired_before,"result screen blocks world shooting")
	sample.encounter_hud.leave.pressed.emit()
	await process_frame
	verify(sample.wave_state=="cleared" and sample.result_dismissed and sample.hero.controls_enabled and not sample.encounter_hud.result.visible,"continue exploration closes the result without immediately retriggering the encounter")
	sample.encounter_hud.retry.pressed.emit()
	verify(sample.player_hp==100. and sample.round_index==0 and sample.defeated_count==0 and sample.parry_count==0 and sample.perfect_dodges==0 and not sample.result_open,"retry starts clean with full HP, one enemy and fresh counters")
	for enemy in alive(sample): enemy.active_ai=false
	sample.invulnerability=0.; sample.hero.dodge_invulnerability=0.; sample.player_hp=20.
	sample.hurt_player(20.,Vector2(sample.hero.position.x,sample.hero.position.z-2.))
	verify(sample.wave_state=="defeated" and sample.hero.knocked_down,"lethal real player damage reaches the existing knocked-down state")
	end_deadline=Time.get_ticks_msec()+2500
	while not sample.result_open and Time.get_ticks_msec()<end_deadline: await process_frame
	verify(sample.result_open and sample.encounter_hud.leave.text=="回小院","failure offers retry and a working route home")
	await capture("defeat")
	sample.encounter_hud.leave.pressed.emit()
	for i in 3: await physics_frame
	verify(sample.wave_state=="waiting" and sample.enemies.is_empty() and sample.player_hp==100. and sample.hero.controls_enabled and not sample.hero.knocked_down,"returning home clears the encounter and restores exploration")
	sample._travel_region("grove")
	for i in 3: await physics_frame
	verify(sample.wave_state=="fighting" and sample.enemies.size()==1 and sample.round_index==0,"re-entering the clearing starts a fresh encounter")
	sample._travel_region("home")
	await process_frame
	verify(Engine.time_scale==1. and sample.shots.is_empty() and not sample.encounter_hud.visible,"leaving cleans time effects, shots and battle HUD")
	print("ENCOUNTER37 ",checks," checks; failures=",failures.size())
	sample.queue_free(); await process_frame
	quit(0 if failures.is_empty() else 1)
