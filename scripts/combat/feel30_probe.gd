extends "res://scripts/ground_lab_probe.gd"
class Actor:
	extends "res://scripts/combat/hero30.gd"
	var test_direction := Vector2.ZERO
	var test_shift := false
	func movement_input() -> Vector2: return test_direction if controls_enabled else Vector2.ZERO
	func dash_key_down() -> bool: return test_shift and controls_enabled
class Sample:
	extends "res://scripts/world/world30.gd"
	func _hero_script() -> Script: return Actor

func wait_real(seconds: float) -> void:
	# Tests manually run many physics steps inside one rendered frame. A newly
	# created SceneTreeTimer would consume that frame's earlier elapsed time too.
	var until := Time.get_ticks_msec()+int(ceil(seconds*1000.))
	while Time.get_ticks_msec()<until: await process_frame

func run() -> void:
	var sample: Node3D=Sample.new()
	root.add_child(sample)
	while not sample.feel_ready: await physics_frame
	sample.start_combat()
	sample.set_cup_phone(false)
	sample.set_physics_process(false)
	sample.set_process(false)
	var hero: CharacterBody3D=sample.hero
	hero.set_physics_process(false)
	for enemy in sample.enemies:
		enemy.set_physics_process(false)
		enemy.position+=Vector3(20,0,0)
	for i in 4: await physics_frame
	verify(sample.reticle.get_script()==preload("res://scripts/combat/muzzle_reticle30.gd") and sample.guide_overlay==null,"dashed 3D guide replaces the paper-thread overlay")
	hero.moving=false; hero.body_clock=.25; hero.render_pose()
	verify(hero.visual.scale.y>1.007 and hero.visual.scale.x<.993 and hero.visual.position.length()<.00001,"legacy idle breathing stretches from the anchored feet")
	hero.moving=true; hero.phase=.25; hero.render_pose()
	verify(absf(hero.visual.rotation.z+.013)<.00001 and absf(hero.visual.scale.y-1.028)<.00001 and hero.visual.position.y>.06,"legacy walking bob, tilt and squash/stretch are restored")
	hero.test_shift=true
	verify(hero.movement_speed()==4.1,"holding Shift never enables the old 6.5m/s continuous sprint")
	hero.test_direction=Vector2.RIGHT
	sample.invulnerability=0.
	var start: Vector3=hero.position
	for i in 11: hero._physics_process(1./60.)
	verify(hero.dash_count==1 and hero.position.x-start.x>2.1 and hero.position.x-start.x<2.5,"one Shift press creates a real ~2.18m single dash")
	verify(hero.dash_cd>0. and not hero.request_dash(Vector2.RIGHT),"single-dash cooldown blocks immediate repeats")
	for i in 50: hero._physics_process(1./60.)
	verify(hero.dash_count==1 and Vector2(hero.velocity.x,hero.velocity.z).length()<4.25,"holding Shift across cooldown does not repeat dash or become sprint")
	hero.test_shift=false; hero._physics_process(1./60.)
	hero.test_shift=true; hero._physics_process(1./60.)
	verify(hero.dash_count==2,"release and press starts a new dash when cooldown is ready")
	hero.test_shift=false; hero.test_direction=Vector2.ZERO
	hero.reset_actions()
	# Momentum must never be used as a substitute for the actual KO state.
	hero.combat_impulse=Vector2.RIGHT*90./sample.Profile.PPM
	hero.render_pose()
	var ko_texture: Texture2D=load("res://assets/hero_pixel/ko_knocked_v2.png")
	verify(hero.visual.texture!=ko_texture,"ordinary 90px knockback keeps the normal pose")
	hero.combat_impulse=Vector2.RIGHT*70./sample.Profile.PPM
	hero.render_pose()
	verify(hero.visual.texture!=ko_texture,"70px dash recovery never switches to KO art")
	hero.story_knocked=true; hero.render_pose()
	verify(hero.visual.texture==ko_texture,"explicit story knockdown can request the KO pose")
	hero.story_knocked=false; hero.knocked_down=true; hero.render_pose()
	verify(hero.visual.texture==ko_texture,"explicit real knockdown uses the KO pose")
	hero.reset_actions(); hero.combat_impulse=Vector2.ZERO; hero.render_pose()
	verify(hero.visual.texture!=ko_texture,"reset clears both explicit knockdown states")
	for facing in ["down","up","left","right"]:
		hero.facing=facing
		verify(hero.request_dash(Vector2.RIGHT),"dash starts with authored facing "+facing)
		hero.render_pose()
		var data: Dictionary=hero.dash_art[facing]
		var foot := Vector2(data.foot[0],data.foot[1])
		if hero.visual.flip_h: foot.x=hero.visual.texture.get_width()-foot.x
		var world: Vector3=sample._pixel_world(hero.visual,foot)
		verify(world.distance_to(hero.global_position)<.0001 and hero.visual.scale==Vector3.ONE,"authored dash is foot-anchored without extra stretching: "+facing)
		hero._spawn_ghost()
		var ghost: Sprite3D=hero.ghosts[-1].node
		verify(ghost.texture==hero.visual.texture and ghost.offset==hero.visual.offset and ghost.flip_h==hero.visual.flip_h,"afterimage retains the exact dash pose and mirrored anchor: "+facing)
		hero.reset_actions()
	hero.facing="down"
	# Actual static wall, including collision during the fast dash.
	var center: Vector2=sample.meadow.landmarks.grove+Vector2(0,3.)
	hero.position=Vector3(center.x,sample.floor_height(center)+.04,center.y)
	hero.reset_physics_interpolation()
	var wall := StaticBody3D.new()
	wall.collision_layer=2
	var collider := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size=Vector3(.2,3,2)
	collider.shape=box
	wall.add_child(collider)
	sample.add_child(wall)
	wall.position=hero.position+Vector3(.7,.7,0)
	for i in 3: await physics_frame
	start=hero.position
	hero.request_dash(Vector2.RIGHT)
	for i in 10: hero._physics_process(1./60.)
	verify(hero.position.x-start.x<.5,"dash uses native collision and cannot tunnel through a wall")
	wall.queue_free()
	hero.reset_actions()
	sample.player_hp=100.; sample.invulnerability=0.
	hero.request_dash(Vector2.RIGHT)
	sample.hurt_player(20.,Vector2(hero.position.x-1.,hero.position.z))
	verify(sample.player_hp==100.,"dash invulnerability rejects native enemy contact damage")
	hero.reset_actions()
	# One close enemy gives the legacy perfect-dodge beat, once per dash.
	var enemy: CharacterBody3D=sample.enemies[0]
	enemy.position=hero.position+Vector3(.7,0,0)
	for i in 3: await physics_frame
	sample._reset_impact_state()
	sample.invulnerability=0.
	hero.request_dash(Vector2.RIGHT)
	hero._physics_process(1./60.)
	verify(sample.perfect_dodges==1 and is_equal_approx(Engine.time_scale,.3) and hero.dodge_invulnerability>=.49,"near-enemy dash triggers the original perfect-dodge slow beat")
	verify(get_nodes_in_group("perfect_dodge_art").size()==1,"perfect dodge uses the original butterfly animation rather than muzzle art")
	hero._physics_process(1./60.)
	verify(sample.perfect_dodges==1,"perfect dodge awards once per dash")
	sample.hitstop(.012,true)
	verify(is_equal_approx(Engine.time_scale,.05),"brief hitstop temporarily overrides slow motion")
	# Check overlap deterministically: a first-use GPU pipeline compilation may
	# legitimately take longer than the whole 220ms reward on a cold driver.
	var clock_start := Time.get_ticks_msec()/1000.
	sample.impact_clock.tick(clock_start+.04)
	verify(is_equal_approx(Engine.time_scale,.05),"legacy latest-writer freeze keeps the extended real-time deadline")
	sample.impact_clock.tick(clock_start+.35)
	verify(Engine.time_scale==1.,"temporary time effects recover on the real clock")
	# Real kills distinguish normal impact from last-enemy closeup.
	sample._reset_impact_state()
	for victim in sample.enemies: victim.hp=1.; victim.dead=false
	sample.enemies[0].receive_hit(1.,Vector3.RIGHT)
	verify(sample.closeup_started<0. and sample.wave_state=="fighting","ordinary kill has a short impact without end-of-wave slow motion")
	verify(is_equal_approx(sample.punch,.32),"every normal kill retains the old +0.32 punch")
	sample._reset_impact_state()
	sample._update_impact_camera(1./60.)
	verify(is_equal_approx(sample.camera_gain,lerpf(1.,5.2/4.,8./60.)),"battle lens uses the original +1.2 baseline and 8*game-delta smoothing")
	sample._reset_impact_state()
	sample.enemies[1].receive_hit(1.,Vector3.RIGHT)
	sample.enemies[2].receive_hit(1.,Vector3.RIGHT)
	verify(sample.wave_state=="cleared" and sample.closeup_started>=0.,"last real kill starts the old death closeup")
	verify(is_equal_approx(sample.camera.fov,42.),"kill zoom is smoothed instead of snapping the lens immediately")
	await wait_real(.44)
	sample._advance_impact_time()
	sample._update_impact_camera(.01)
	verify(is_equal_approx(Engine.time_scale,.25) and sample.closeup_weight>.99,"closeup pushes first, then runs at 0.25x speed")
	verify(sample.camera.fov<42. and is_equal_approx(sample.camera.rotation_degrees.x,-25.),"closeup zoom keeps the approved 25-degree camera pitch")
	await wait_real(.52)
	sample._advance_impact_time()
	verify(Engine.time_scale==1.,"closeup slow motion expires before the camera return finishes")
	await wait_real(.2)
	sample._update_impact_camera(.01)
	verify(sample.closeup_weight==0.,"death closeup releases its cinematic focus")
	# Normal hurt, actual death and restart each exercise the rendered actor state.
	sample.start_combat(); sample.set_cup_phone(false)
	for victim in sample.enemies: victim.set_physics_process(false)
	hero.set_physics_process(false)
	sample.invulnerability=0.; hero.reset_actions()
	sample.hurt_player(20.,Vector2(hero.position.x-1.,hero.position.z))
	hero.render_pose()
	verify(sample.player_hp==80. and hero.visual.texture!=ko_texture,"real ordinary damage never displays the knocked-down frame")
	verify(sample.hp_shake_left==.25 and sample.hurt_flash==.2,"ordinary hurt restores the original HUD shake and red-flash duration")
	sample.invulnerability=0.; sample.hurt_player(100.,Vector2(hero.position.x-1.,hero.position.z))
	verify(hero.knocked_down and hero.visual.texture==ko_texture and is_equal_approx(Engine.time_scale,.25),"actual defeat displays KO and the original 0.25x death beat")
	sample.set_temp_time_scale(.25,.5,.2)
	sample.start_combat()
	await wait_real(.25)
	sample._advance_impact_time()
	verify(Engine.time_scale==1. and sample.impact_clock.events.is_empty(),"restart cancels delayed slow motion and all pending feedback")
	sample.set_temp_time_scale(.3,.22)
	sample._unhandled_input(event(KEY_F7))
	verify(Engine.time_scale==1. and sample.impact_clock.events.is_empty(),"debug pause cancels pending time effects")
	# Isolate GPU-visible walking tilt: same authored frame, opposite lean.
	sample.process_mode=Node.PROCESS_MODE_DISABLED
	hero.moving=true; hero.phase=.25; hero.render_pose(); hero.visual.reset_physics_interpolation()
	var a: Image=await snapshot()
	hero.phase=.75; hero.render_pose(); hero.visual.reset_physics_interpolation()
	var b: Image=await snapshot()
	verify(changed(a,b,Rect2i(Vector2i.ZERO,a.get_size()))>20,"walking tilt changes actual GPU pixels rather than being discarded by billboarding")
	b.save_png("res://docs/captures/world_restart/feel30_walk.png")
	sample.set_temp_time_scale(.25,1.)
	sample.queue_free()
	await process_frame
	verify(Engine.time_scale==1.,"leaving the scene restores global time scale")
	print("FEEL30 ",checks," checks; failures=",failures.size())
	quit(0 if failures.is_empty() else 1)
