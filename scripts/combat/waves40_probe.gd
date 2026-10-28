extends "res://scripts/ground_lab_probe.gd"
class Actor:
	extends "res://scripts/combat/hero36.gd"
	var test_direction := Vector2.ZERO
	func movement_input() -> Vector2: return test_direction
	func dash_key_down() -> bool: return false
	func parry_key_down() -> bool: return false
class Sample:
	extends "res://scripts/world/world40.gd"
	func _hero_script() -> Script: return Actor
	func fire_input_held() -> bool: return false

func alive(sample: Node3D) -> Array[CharacterBody3D]:
	var found: Array[CharacterBody3D]=[]
	for enemy in sample.enemies:
		if is_instance_valid(enemy) and not enemy.dead: found.append(enemy)
	return found

func clear_wave(sample: Node3D) -> void:
	var deadline := Time.get_ticks_msec()+25000
	var shot_clock := 0.
	while not sample.wave_reward_pending and sample.wave_state=="fighting" and Time.get_ticks_msec()<deadline:
		var targets := alive(sample)
		for enemy in targets: enemy.active_ai=false
		if not targets.is_empty():
			var enemy: CharacterBody3D=targets[0]
			var toward := Vector2(enemy.position.x-sample.hero.position.x,enemy.position.z-sample.hero.position.z)
			sample.hero.test_direction=toward.normalized() if toward.length()>4. else Vector2.ZERO
			shot_clock+=sample.get_physics_process_delta_time()
			if sample.buffs.level("slingshot")==0:
				if shot_clock>=sample.attack_cooldown():
					shot_clock=0.; sample.fire_at(enemy.position+Vector3.UP*.70)
			elif shot_clock>=sample.charge_time()+.25:
				shot_clock=0.; sample._release_charged(enemy.position+Vector3.UP*.70,1.)
		await physics_frame
	sample.hero.test_direction=Vector2.ZERO

func wait_draft(sample: Node3D) -> void:
	var deadline := Time.get_ticks_msec()+3000
	while not sample.draft_open and Time.get_ticks_msec()<deadline: await process_frame
	var ready_at := Time.get_ticks_msec()+500
	while Time.get_ticks_msec()<ready_at: await process_frame

func capture(name: String) -> void:
	var shot: Image=await snapshot()
	shot.save_png("res://docs/captures/world_restart/waves40_"+name+".png")

func choose(sample: Node3D,id: String) -> bool:
	for i in sample.draft_choices.size():
		if sample.draft_choices[i].id==id: return sample.choose_buff(i)
	return false

func run() -> void:
	var sample: Node3D=Sample.new()
	root.add_child(sample)
	while not sample.buff39_ready: await physics_frame
	sample.set_process_unhandled_input(false); sample.start_combat()
	sample.invulnerability=999.; sample.player_hp=80.; sample.parry_count=2; sample.perfect_dodges=1; sample.hurt_count=1
	await clear_wave(sample)
	verify(sample.defeated_count==1 and sample.round_index==0 and sample.wave_reward_pending,"the first single-enemy wave earns a reward immediately")
	await wait_draft(sample)
	verify(sample.draft_open and sample.draft_ui.panels.size()==3,"first-wave victory visibly opens three selectable cards")
	verify(sample.draft_ui.subtitle.text.contains("第 1 / 3 波"),"card prompt identifies the completed wave")
	await capture("wave1_draft")
	var until := Time.get_ticks_msec()+2500
	while Time.get_ticks_msec()<until: await process_frame
	verify(sample.round_index==0 and alive(sample).is_empty() and sample.draft_open,"next wave cannot auto-spawn while the player is reading cards")
	var shots_before: int=sample.fired_count
	verify(choose(sample,"eye_exercise"),"first wave can grant eye exercise")
	verify(sample.round_index==1 and alive(sample).size()==2 and not sample.draft_open and not sample.result_open,"choosing a first-wave card resumes with the second two-enemy wave")
	verify(sample.player_hp==80. and sample.defeated_count==1 and sample.fired_count==shots_before and sample.parry_count==2 and sample.perfect_dodges==1 and sample.hurt_count==1,"wave selection preserves HP and all encounter statistics")
	verify(is_equal_approx(sample.attack_cooldown(),.14/1.5),"the selected buff applies during the very next wave")
	await clear_wave(sample)
	verify(sample.defeated_count==3 and sample.round_index==1 and sample.wave_reward_pending,"the second wave awards its own card after only its two enemies")
	# Reproduce walking out of the old trial radius during the finish beat.
	var center: Vector2=sample.meadow.landmarks.grove
	sample.hero.position=Vector3(center.x+22.2,sample.floor_height(center+Vector2(22.2,0))+.1,center.y)
	await wait_draft(sample)
	verify(sample.draft_open and sample.wave_state=="fighting","earned wave reward survives crossing the old auto-cancel boundary")
	await capture("wave2_draft")
	verify(choose(sample,"slingshot"),"second wave can grant the slingshot")
	verify(sample.round_index==2 and alive(sample).size()==3 and sample.player_hp==80. and sample.defeated_count==3,"second selection enters the last wave without restarting the encounter")
	verify(Vector2(sample.hero.position.x,sample.hero.position.z).distance_to(center)<21.,"continuing after an edge victory returns to the clearing instead of immediately cancelling the next wave")
	await clear_wave(sample)
	verify(sample.wave_state=="cleared" and sample.defeated_count==6,"third wave still completes the six-enemy encounter")
	await wait_draft(sample)
	verify(sample.draft_open and not sample.wave_reward_pending and sample.draft_ui.subtitle.text.contains("第三波"),"last wave also offers a reward after the existing finale")
	await capture("wave3_draft")
	verify(choose(sample,"cup_phone"),"third wave can grant paper cup telephone")
	verify(sample.round_index==0 and alive(sample).size()==1 and sample.defeated_count==0 and sample.player_hp==100.,"third selection begins a fresh encounter rather than an out-of-range fourth wave")
	verify(sample.buffs.levels.size()==3 and sample.cup_phone_enabled,"all three per-wave choices carry into the next encounter")
	sample._unhandled_input(event(KEY_F5))
	verify(sample.buffs.levels.size()==3 and not sample.wave_reward_pending and not sample.draft_open,"F5 retains memories and clears pending reward state")
	sample._unhandled_input(event(KEY_F8))
	verify(sample.buffs.levels.is_empty() and not sample.wave_reward_pending and not sample.draft_open,"F8 clears both buffs and per-wave reward state")
	# Exhausting the intentionally small initial pool must not strand a wave.
	sample.buffs.levels={"slingshot":2,"eye_exercise":2,"cup_phone":1}
	for enemy in alive(sample): enemy.receive_hit(100.,Vector3.RIGHT)
	sample.wave_reward_at=Time.get_ticks_msec()/1000.-1.
	sample._process(0.)
	verify(sample.round_index==1 and alive(sample).size()==2 and not sample.wave_reward_pending and not sample.draft_open,"a fully collected card pool still advances between waves without a soft lock")
	print("WAVES40 ",checks," checks; failures=",failures.size())
	sample.queue_free(); await process_frame
	quit(0 if failures.is_empty() else 1)
