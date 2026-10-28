extends "res://scripts/ground_lab_probe.gd"
class Actor:
	extends "res://scripts/combat/hero36.gd"
	var test_direction := Vector2.ZERO
	func movement_input() -> Vector2: return test_direction
	func dash_key_down() -> bool: return false
	func parry_key_down() -> bool: return false
class Sample:
	extends "res://scripts/world/world39.gd"
	var held := false
	var test_target := Vector3.INF
	func _hero_script() -> Script: return Actor
	func fire_input_held() -> bool: return held
	func aim_at_screen(point: Vector2) -> Vector3:
		return test_target if test_target.is_finite() else super.aim_at_screen(point)

func alive(sample: Node3D) -> Array[CharacterBody3D]:
	var result: Array[CharacterBody3D]=[]
	for enemy in sample.enemies:
		if is_instance_valid(enemy) and not enemy.dead: result.append(enemy)
	return result
func card_index(sample: Node3D,id: String) -> int:
	for i in sample.draft_choices.size():
		if sample.draft_choices[i].id==id: return i
	return -1
func capture(name: String) -> void:
	var shot: Image=await snapshot()
	shot.save_png("res://docs/captures/world_restart/buffs39_"+name+".png")
func finish(sample: Node3D) -> void:
	print("BUFFS39 ",checks," checks; failures=",failures.size())
	sample.queue_free(); await process_frame
	quit(0 if failures.is_empty() else 1)
func offer_fixture(sample: Node3D) -> void:
	sample._clear_combat_shots(); sample.impact_clock.clear()
	sample.wave_state="cleared"; sample.result_open=false; sample.result_dismissed=false
	sample.reward_offered=false; sample.result_at=Time.get_ticks_msec()/1000.-1.
	sample._process(1./60.)
	var ready_at := Time.get_ticks_msec()+400
	while Time.get_ticks_msec()<ready_at: await process_frame

func run() -> void:
	var sample: Node3D=Sample.new()
	root.add_child(sample)
	while not sample.buff39_ready: await physics_frame
	sample.set_process_unhandled_input(false); sample.start_combat()
	verify(not sample.cup_phone_enabled and sample.buffs.levels.is_empty(),"new run begins with a following goose and no unearned buffs")
	verify(sample.buffs.eligible().size()==3,"first reward contains the three implemented original cards")
	sample.invulnerability=999.; sample.weapon_rng.seed=390039
	var clock := 0.
	var deadline := Time.get_ticks_msec()+65000
	# AI is disabled only for the native projectile / six-kill reward fixture.
	while sample.wave_state=="fighting" and Time.get_ticks_msec()<deadline:
		var targets := alive(sample)
		for enemy in targets: enemy.active_ai=false
		if not targets.is_empty() and sample.between_left<=0.:
			var enemy: CharacterBody3D=targets[0]
			var toward := Vector2(enemy.position.x-sample.hero.position.x,enemy.position.z-sample.hero.position.z)
			sample.hero.test_direction=toward.normalized() if toward.length()>4. else Vector2.ZERO
			clock+=sample.get_physics_process_delta_time()
			if clock>=sample.attack_cooldown(): clock=0.; sample.fire_at(enemy.position+Vector3.UP*.70)
		else: sample.hero.test_direction=Vector2.ZERO
		await physics_frame
	sample.hero.test_direction=Vector2.ZERO
	verify(sample.wave_state=="cleared" and sample.defeated_count==6 and sample.landed_hits>=72,"native projectile damage completes the six-enemy encounter before awarding a draft")
	deadline=Time.get_ticks_msec()+3000
	while not sample.draft_open and Time.get_ticks_msec()<deadline: await process_frame
	verify(sample.draft_open and sample.combat_paused and not sample.hero.controls_enabled and sample.draft_ui.panels.size()==3,"victory camera finishes before a paused three-card reward opens")
	if not sample.draft_open: await finish(sample); return
	var ready_at := Time.get_ticks_msec()+450
	while Time.get_ticks_msec()<ready_at: await process_frame
	await capture("first_draft")
	verify(not sample.choose_buff(-1) and not sample.choose_buff(3),"invalid card indices cannot grant a buff")
	await create_timer(.30,true,false,true).timeout
	var index := card_index(sample,"slingshot")
	sample.draft_ui.panels[index].pressed.emit()
	verify(sample.buffs.level("slingshot")==1 and sample.wave_state=="fighting" and not sample.draft_open and not sample.combat_paused,"clicking an original card grants its effect and starts the next encounter")
	verify(not sample.choose_buff(index) and sample.buffs.level("slingshot")==1,"the same reward cannot be claimed twice")
	sample._unhandled_input(event(KEY_F5))
	verify(sample.buffs.level("slingshot")==1 and sample.player_hp==100.,"F5 retries the encounter without deleting acquired memories")
	for enemy in alive(sample): enemy.active_ai=false; enemy.set_physics_process(false)
	sample.set_physics_process(false); sample.hero.set_physics_process(false)
	# Create a two-target lane to test native charged-ray penetration precisely.
	for enemy in alive(sample): enemy.receive_hit(100.,Vector3.RIGHT)
	sample._spawn_next_round()
	var actors := alive(sample)
	for enemy in actors: enemy.active_ai=false; enemy.set_physics_process(false); enemy.hp=30.
	var center: Vector2=sample.meadow.landmarks.grove
	var origin := Vector3(center.x,sample.floor_height(center)+.04,center.y+2.)
	sample.hero.position=origin; sample.hero.reset_physics_interpolation()
	actors[0].position=origin+Vector3(0,0,-2.)
	actors[1].position=origin+Vector3(0,0,-3.1)
	for enemy in actors: enemy._render_legacy(0.); enemy.reset_physics_interpolation()
	sample.test_target=actors[0].position+Vector3.UP*.65
	sample.goose.update_follow(0.,sample.test_target,true)
	for i in 3: await physics_frame
	sample._clear_combat_shots(); sample.cooldown=0.; sample.fire_needs_release=false
	sample.held=true; sample._step_fire_input(.36)
	verify(sample.charge_active and sample.shots.is_empty() and absf(sample.charge_ratio()-.5)<.001,"slingshot holds fire and visibly charges instead of auto-firing ordinary shots")
	sample._step_fire_input(.36)
	verify(sample.charge_ready and is_equal_approx(sample.charge_ratio(),1.),"first-tier full charge takes the original 0.72 seconds")
	await capture("charged")
	sample.held=false; sample._step_fire_input(0.)
	verify(sample.shots.size()==1 and sample.cooldown==.25,"release emits one heavy projectile and applies the original 0.25s refire gate")
	var heavy: Dictionary=sample.shots[-1]
	verify(is_equal_approx(sample.damage_for_shot(heavy),12.) and heavy.charged and is_equal_approx(heavy.velocity.length(),750./sample.Profile.PPM),"full charge carries original 12x damage and native heavy-projectile speed")
	for i in 20: sample._step_shots(1./60.)
	verify(actors[0].hp==18. and actors[1].hp==18. and heavy.hit_rids.size()==2,"one charged native sweep pierces two enemies and damages each exactly once")
	sample._clear_combat_shots()
	actors[0].hp=30.; actors[1].hp=30.
	var wall := StaticBody3D.new(); wall.collision_layer=2
	var collider := CollisionShape3D.new(); var box := BoxShape3D.new()
	box.size=Vector3(2.,1.5,.16); collider.shape=box; wall.add_child(collider)
	wall.position=origin+Vector3(0,.7,-2.55); sample.add_child(wall)
	for i in 3: await physics_frame
	sample._release_charged(sample.test_target,1.)
	var blocks: int=sample.blocks
	for i in 20: sample._step_shots(1./60.)
	verify(actors[0].hp==18. and actors[1].hp==30. and sample.blocks==blocks+1,"heavy projectile pierces bodies but stops at a real wall")
	wall.queue_free(); sample._clear_combat_shots()
	verify(sample.buffs.apply("eye_exercise") and is_equal_approx(sample.attack_cooldown(),.14/1.5),"first eye-exercise card grants the original 50 percent fire-rate bonus")
	sample.fire_at(sample.hero.position+Vector3.FORWARD*4.)
	var tracking: Dictionary=sample.shots[-1]
	tracking.node.position=origin+Vector3.UP*.7
	actors[0].position=tracking.node.position+Vector3(1,0,-3); actors[1].dead=true
	tracking.velocity=Vector3(0,0,-11.)
	sample._steer_shot(tracking,.1)
	var first_turn := absf(Vector2(0,-1).angle_to(Vector2(tracking.velocity.x,tracking.velocity.z)))
	verify(first_turn>.24 and first_turn<=.2501 and absf(tracking.velocity.length()-11.)<.001,"first-tier guidance turns at no more than 2.5 rad/s and preserves projectile speed")
	verify(sample.buffs.apply("eye_exercise") and is_equal_approx(sample.attack_cooldown(),.14/1.875),"second eye-exercise card compounds the original 25 percent rate upgrade")
	tracking.velocity=Vector3(0,0,-11.); sample._steer_shot(tracking,.1)
	verify(absf(Vector2(0,-1).angle_to(Vector2(tracking.velocity.x,tracking.velocity.z)))>first_turn,"second-tier tracking steers more strongly toward the target")
	actors[0].position=tracking.node.position+Vector3(0,0,3.)
	tracking.velocity=Vector3(0,0,-11.); sample._steer_shot(tracking,.1)
	verify(tracking.velocity==Vector3(0,0,-11.),"guidance does not turn toward targets outside its forward cone")
	sample._clear_combat_shots()
	await offer_fixture(sample)
	index=card_index(sample,"cup_phone")
	verify(sample.draft_ui.panels.size()==2 and index>=0,"maxed cards leave the reward pool and remaining choices center correctly")
	await capture("two_choices")
	sample._unhandled_input(event(KEY_1+index))
	verify(sample.buffs.level("cup_phone")==1 and sample.cup_phone_enabled and sample.goose.cup_phone,"keyboard selection unlocks the existing free-flight/contact-damage goose")
	verify(not sample.buffs.apply("cup_phone") and not sample.buffs.apply("eye_exercise"),"one-time and tier caps cannot be exceeded")
	for enemy in alive(sample): enemy.active_ai=false; enemy.set_physics_process(false)
	await offer_fixture(sample)
	verify(sample.draft_choices.size()==1 and sample.draft_choices[0].id=="slingshot" and sample.buffs.description(sample.draft_choices[0]).contains("14"),"last remaining upgrade offers the original second-tier description")
	var chose_last: bool=sample.choose_buff(0)
	verify(sample.buffs.level("slingshot")==2 and is_equal_approx(sample.charge_time(),.72/1.875*.85),"second slingshot tier preserves the faster-charge combination with eye exercise")
	if not chose_last: await finish(sample); return
	for enemy in alive(sample): enemy.active_ai=false; enemy.set_physics_process(false)
	sample._release_charged(sample.hero.position+Vector3.FORWARD*4.,1.)
	verify(is_equal_approx(sample.damage_for_shot(sample.shots[-1]),14.),"second-tier full charge deals the original 14x damage")
	await offer_fixture(sample)
	verify(not sample.draft_open and sample.result_open and sample.encounter_hud.result.visible,"an exhausted small card pool falls back to a working result screen")
	await capture("collected")
	sample.continue_exploring(); sample._travel_region("home")
	verify(sample.buffs.levels.size()==3 and sample.buffs.level("slingshot")==2,"exploration and travel retain acquired memories")
	sample._unhandled_input(event(KEY_F8))
	verify(sample.buffs.levels.is_empty() and not sample.cup_phone_enabled and not sample.charge_active and sample.shots.is_empty() and sample.round_index==0,"F8 creates a clean run without retained buffs, charge state or projectiles")
	await finish(sample)
