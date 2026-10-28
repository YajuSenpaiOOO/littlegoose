extends "res://scripts/ground_lab_probe.gd"
class Actor:
	extends "res://scripts/combat/hero34.gd"
	var test_button := false
	func movement_input() -> Vector2: return Vector2.ZERO
	func dash_key_down() -> bool: return false
	func parry_key_down() -> bool: return test_button and controls_enabled
class Sample:
	extends "res://scripts/world/world34.gd"
	var scripted_fire := false
	func _hero_script() -> Script: return Actor
	func fire_at(target: Vector3) -> void:
		if scripted_fire: super.fire_at(target)

func lunge(enemy: CharacterBody3D,at: Vector3) -> void:
	enemy.position=at; enemy.active_ai=true; enemy.dead=false; enemy.hopping=false
	enemy.attack_phase="lunge"; enemy.phase_clock=0.; enemy.attack_direction=Vector2.DOWN
	enemy.attack_distance=3.; enemy.attack_connected=false; enemy.impulse=Vector2.ZERO

func run() -> void:
	var sample: Node3D=Sample.new()
	root.add_child(sample)
	while not sample.parry_ready: await physics_frame
	sample.set_process_unhandled_input(false)
	sample.start_combat(); sample.set_cup_phone(false)
	for enemy in sample.enemies: enemy.active_ai=false; enemy.set_physics_process(false)
	for i in 25: await physics_frame
	sample.set_physics_process(false); sample.set_process(false)
	var hero: CharacterBody3D=sample.hero
	hero.set_physics_process(false)
	# Use the open clearing, not the exploration spawn beside a tree collider.
	var center: Vector2=sample.meadow.landmarks.grove
	hero.position=Vector3(center.x,sample.floor_height(center)+.04,center.y+2.)
	hero.reset_physics_interpolation(); sample._update_camera(0.,true)
	var origin: Vector3=hero.position
	var enemy: CharacterBody3D=sample.enemies[0]
	verify(not sample.show_attack_cue and not enemy.cue.visible and not enemy.cue.is_processing(),"ground arrows are absent by default and their renderer is inactive")
	for facing in ["down","left","right","up"]:
		hero.reset_actions(); hero.facing=facing
		verify(hero.request_parry(),"guard starts with authored direction "+facing)
		hero.render_pose()
		var pose: Dictionary=hero.parry_art[facing]
		var foot := Vector2(pose.foot[0],pose.foot[1])
		verify(sample._pixel_world(hero.visual,foot).distance_to(hero.global_position)<.0001,"guard texture stays foot-anchored: "+facing)
		verify(hero.visual.texture!=load("res://assets/hero_pixel/ko_knocked_v2.png"),"guard never substitutes the knocked-down frame: "+facing)
	hero.reset_actions(); hero.test_button=true
	hero._physics_process(1./60.)
	for i in 80: hero._physics_process(1./60.)
	verify(hero.parry_starts==1 and hero.parry_whiffs==1,"holding right-click cannot repeat guard when its cooldown expires")
	hero.test_button=false; hero._physics_process(1./60.)
	hero.test_button=true; hero._physics_process(1./60.)
	verify(hero.parry_starts==2,"release and press can start another guard after the old cooldown")
	hero.test_button=false; hero.reset_actions(); hero.request_parry()
	hero._physics_process(.20)
	verify(hero.parry_t==0. and hero.parry_cd>.79 and hero.parry_whiffs==1,"an empty 0.18s guard keeps the original 1s miss cooldown")
	sample._reset_impact_state(); sample.invulnerability=0.; sample.player_hp=100.
	hero.position=origin; hero.controls_enabled=true
	lunge(enemy,origin+Vector3(0,0,-1.7))
	hero.request_parry()
	enemy._physics_process(1./60.)
	verify(sample.parry_count==1 and sample.player_hp==100. and enemy.parried_count==1,"native approaching lunge is intercepted before player damage")
	verify(enemy.attack_phase=="recover" and enemy.parry_stun>.7 and enemy.impulse.length()>4.,"successful parry knocks the attacker away into an extended recovery")
	verify(hero.parry_t<=.03 and is_equal_approx(hero.parry_cd,.06),"success contracts the catch window and returns the old short re-input gate")
	verify(sample.combo==1 and is_equal_approx(Engine.time_scale,.05) and is_equal_approx(sample.stop_duration,.09),"first parry owns its 90ms hitstop and one combo award")
	verify(get_nodes_in_group("parry_art").size()>0,"original drawn impact and directional sweep are instantiated")
	hero.render_pose(); sample.status_next=0; sample._status()
	var impact: Image=await snapshot()
	impact.save_png("res://docs/captures/world_restart/parry34_impact.png")
	# Director checks: use an explicit same-chain timestamp, independent of GPU warmup.
	sample.parry_chain_last=Time.get_ticks_msec()/1000.
	sample.parry_success(origin+Vector3.UP*.65,Vector3.RIGHT)
	verify(sample.parry_chain==2 and is_equal_approx(sample.stop_duration,.12),"second same-chain parry advances to the old 120ms beat")
	sample.parry_chain_last=Time.get_ticks_msec()/1000.
	sample.parry_success(origin+Vector3.UP*.65,Vector3.RIGHT)
	verify(sample.parry_chain==3 and sample.reflected_fans==1 and sample.shots.size()==3,"third parry creates the original three-shot counter fan")
	var fan_ok := true
	for shot in sample.shots: fan_ok=fan_ok and is_equal_approx(sample.damage_for_shot(shot),1.5) and shot.life==1.2
	verify(fan_ok,"counter projectiles carry real 1.5 damage and original 1.2s life")
	var beats: int=sample.parry_tier_beats
	sample.parry_chain_last=Time.get_ticks_msec()/1000.
	sample.parry_success(origin+Vector3.UP*.65,Vector3.RIGHT)
	verify(sample.parry_tier_beats==beats and sample.reflected_fans==1,"extra same-tier catches do not replay the heavy stop or counter fan")
	verify(sample.impact_clock.events.filter(func(e: Dictionary) -> bool: return e.get("group","")=="parry").size()==1,"higher tiers cancel the previous pending slow-motion cue")
	sample.impact_clock.clear()
	var counter_hp: float=enemy.hp
	for i in 90:
		sample._step_shots(1./60.)
		await physics_frame
		if enemy.hp<counter_hp: break
	verify(enemy.hp<counter_hp and is_zero_approx(fmod(counter_hp-enemy.hp,1.5)),"native counter-fan collision deals actual multiples of 1.5 damage")
	sample._reset_impact_state(); sample._clear_combat_shots()
	sample.invulnerability=0.; sample.player_hp=100.; hero.position=origin
	hero.request_parry(); hero._physics_process(.20)
	lunge(enemy,origin+Vector3(0,0,-1.7))
	for i in 20: enemy._physics_process(1./60.)
	verify(sample.parry_count==0 and sample.player_hp==80.,"pressing too early expires and a real lunge can still hit")
	sample._reset_impact_state(); sample.invulnerability=.5
	hero.request_parry()
	verify(not hero.can_parry(),"hurt invulnerability cannot farm a free successful parry")
	sample._reset_impact_state(); sample.invulnerability=0.
	hero.request_dash(Vector2.RIGHT)
	verify(not hero.request_parry(),"dash and guard cannot start simultaneously")
	sample._reset_impact_state(); hero.position=origin
	hero.request_parry()
	sample.scripted_fire=true; sample.fire_at(origin+Vector3(3,.8,0)); sample.scripted_fire=false
	verify(sample.shots.size()==1 and hero.parry_t>0.,"guard belongs to the heroine and does not block goose shooting")
	sample._clear_combat_shots()
	sample._unhandled_input(event(KEY_DELETE))
	enemy.attack_phase="windup"; enemy.cue._process(0.)
	verify(sample.show_attack_cue and enemy.cue.visible,"Delete restores ground direction cues for comparison")
	sample._unhandled_input(event(KEY_DELETE))
	verify(not sample.show_attack_cue and not enemy.cue.visible,"Delete returns to action-only tells")
	sample.start_combat()
	verify(hero.parry_t==0. and hero.parry_cd==0. and sample.parry_count==0 and sample.impact_clock.events.is_empty(),"restart clears guard, chain, feedback and pending slow motion")
	sample.queue_free(); await process_frame
	verify(Engine.time_scale==1.,"leaving restores global time scale")
	print("PARRY34 ",checks," checks; failures=",failures.size())
	quit(0 if failures.is_empty() else 1)
