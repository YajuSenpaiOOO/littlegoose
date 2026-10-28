extends "res://scripts/ground_lab_probe.gd"
class Sample:
	extends "res://scripts/world/world33.gd"
	var scripted_fire := false
	func fire_at(target: Vector3) -> void:
		if scripted_fire: super.fire_at(target)

func run() -> void:
	var sample: Node3D=Sample.new()
	root.add_child(sample)
	while not sample.encounter_ready: await physics_frame
	sample.set_process_unhandled_input(false)
	sample.start_combat(); sample.set_cup_phone(false)
	sample.hero.controls_enabled=false
	for enemy in sample.enemies: enemy.active_ai=false; enemy.set_physics_process(false)
	for i in 25: await physics_frame
	verify(sample.enemies.size()==3 and sample.tactical_combat,"trial starts three ordinary enemies with tactical attack phases")
	verify(sample.jelly_fx.airborne.multimesh.mesh is QuadMesh and sample.jelly_fx.airborne.multimesh.use_custom_data,"airborne jelly uses the authored sheet with per-instance variants")
	verify(sample.jelly_fx.sugar.material_override.get_shader_parameter("sheet").resource_path.ends_with("sugar_sheet_v1.png"),"hard candy uses the newly painted fragments instead of cropped spark art")
	verify(sample.jelly_fx.ground.material_override.get_shader_parameter("sheet").resource_path.ends_with("jelly_sheet_v1.png"),"ground residue uses the separately painted top-down jelly splats")
	var victim: CharacterBody3D=sample.enemies[0]
	var hero: CharacterBody3D=sample.hero
	var center: Vector2=sample.meadow.landmarks.grove
	victim.position=Vector3(center.x,sample.floor_height(center)+.06,center.y+1.)
	sample.scripted_fire=true; sample.fire_at(victim.position+Vector3.UP*.8); sample.scripted_fire=false
	for i in 100:
		await physics_frame
		if sample.landed_hits>0: break
	verify(sample.landed_hits==1 and victim.hp==11. and Engine.time_scale==1.,"actual native projectile keeps one damage and no ordinary global freeze")
	verify(sample.jelly_fx.bits.size()==4 and sample.jelly_fx.drops.size()==2,"painted sugar and jelly retain their existing bounded motion lifecycles")
	for i in 6: await physics_frame
	var art: Image=await snapshot()
	art.save_png("res://docs/captures/world_restart/encounter33_materials.png")
	sample.set_physics_process(false); hero.set_physics_process(false)
	sample._reset_impact_state(); sample.player_hp=100.; sample.invulnerability=0.
	var origin: Vector3=hero.global_position
	victim.active_ai=true; victim.impulse=Vector2.ZERO; victim.hopping=false
	victim.position=origin+Vector3(0,0,-2.6); victim.phase_clock=.2
	victim._physics_process(1./60.)
	verify(victim.attack_phase=="windup" and victim.attacks_started==1,"nearby enemy visibly winds up before its first lunge")
	var other: CharacterBody3D=sample.enemies[1]
	other.active_ai=true; other.hopping=false; other.position=origin+Vector3(2.,0,-2.6); other.phase_clock=.2
	other._physics_process(1./60.)
	verify(other.attack_phase!="windup","three enemies cannot all start their attack on the same beat")
	victim.cue._process(0.)
	verify(victim.cue.visible and victim.cue.mesh!=null and victim.cue.global_position.length()<.001,"ground direction cue is rendered in world coordinates without double translation")
	sample.status_next=0; sample._status()
	var warning: Image=await snapshot()
	warning.save_png("res://docs/captures/world_restart/encounter33_windup.png")
	victim.phase_clock=.2
	var locked: Vector2=victim.attack_direction
	hero.position+=Vector3.RIGHT*1.5
	victim._physics_process(.1)
	verify(victim.attack_direction.distance_to(locked)<.0001,"committed windup does not turn to track the player's dodge")
	hero.position=origin
	victim.position=origin+Vector3(0,0,-.3); victim.phase_clock=.3
	victim._physics_process(1./60.)
	verify(sample.player_hp==100.,"touching a winding-up enemy does not cause invisible contact damage")
	victim.attack_phase="recover"; victim.phase_clock=.1
	victim._physics_process(1./60.)
	verify(sample.player_hp==100.,"recovery is a safe counterattack window rather than continuous body damage")
	victim.attack_phase="windup"; victim.phase_clock=.1
	verify(not sample.can_perfect_dodge(victim),"early windup does not award a free perfect dodge")
	victim.phase_clock=.42
	verify(sample.can_perfect_dodge(victim),"late committed windup can reward a well-timed near dodge")
	# Real swept lunge: one hit across the body, not repeated overlap damage.
	sample._reset_impact_state(); sample.invulnerability=0.; sample.player_hp=100.
	victim.position=origin+Vector3(0,0,-1.7); victim.impulse=Vector2.ZERO
	victim.attack_phase="lunge"; victim.phase_clock=0.; victim.attack_direction=Vector2.DOWN; victim.attack_distance=3.; victim.attack_connected=false
	var hurt_before: int=sample.hurt_count
	for i in 24: victim._physics_process(1./60.)
	verify(sample.player_hp==80. and sample.hurt_count==hurt_before+1,"native swept lunge damages the player exactly once")
	verify(victim.attack_phase=="recover" and victim.attack_landings==1,"lunge lands and enters the explicit recovery phase")
	var old_hp: float=victim.hp
	victim.receive_hit(1.,Vector3.RIGHT)
	verify(victim.hp==old_hp-1. and victim.attack_phase=="recover","enemy remains hittable throughout its recovery window")
	# Native dash should distinguish idle bodies from actual threats.
	sample._reset_impact_state(); sample.invulnerability=0.; sample.player_hp=100.
	hero.controls_enabled=true; hero.position=origin
	for enemy in sample.enemies: enemy.attack_phase="recover"; enemy.position=origin+Vector3(15,0,0)
	victim.position=origin+Vector3(.7,0,0)
	hero.request_dash(Vector2.RIGHT); hero._physics_process(1./60.)
	verify(sample.perfect_dodges==0,"dashing past a harmless resting body no longer farms perfect-dodge rewards")
	sample._reset_impact_state(); sample.invulnerability=0.
	victim.position=hero.position+Vector3(.7,0,0); victim.attack_phase="lunge"
	hero.request_dash(Vector2.RIGHT); hero._physics_process(1./60.)
	verify(sample.perfect_dodges==1 and is_equal_approx(Engine.time_scale,.3),"actual near-threat dash retains butterfly, slow motion and invulnerability reward")
	sample._reset_impact_state()
	sample.jelly_fx.burst(origin+Vector3.UP*.8,Vector3.RIGHT,false)
	for i in 100: sample.jelly_fx._process(1./120.)
	verify(sample.jelly_fx.landed>=2 and sample.jelly_fx.marks.size()>=2,"painted droplets still collide with terrain and leave temporary painted splats")
	var stains: Image=await snapshot()
	stains.save_png("res://docs/captures/world_restart/encounter33_splats.png")
	sample._unhandled_input(event(KEY_END))
	verify(not sample.tactical_combat and sample.jelly_fx.marks.is_empty(),"End restores the earlier chase AI with a clean round")
	sample._unhandled_input(event(KEY_END))
	verify(sample.tactical_combat and sample.combat_clock33==0. and sample.next_attack33==0.,"restart resets all attack scheduling state")
	sample.queue_free(); await process_frame
	verify(Engine.time_scale==1.,"leaving the encounter restores global time")
	print("ENCOUNTER33 ",checks," checks; failures=",failures.size())
	quit(0 if failures.is_empty() else 1)
