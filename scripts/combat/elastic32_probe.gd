extends "res://scripts/ground_lab_probe.gd"
class Sample:
	extends "res://scripts/world/world32.gd"
	var scripted_fire := false
	func fire_at(target: Vector3) -> void:
		if scripted_fire: super.fire_at(target)

func run() -> void:
	var sample: Node3D=Sample.new()
	root.add_child(sample)
	while not sample.elastic_ready: await physics_frame
	sample.set_process_unhandled_input(false)
	sample.start_combat(); sample.set_cup_phone(false)
	sample.hero.controls_enabled=false
	for enemy in sample.enemies: enemy.set_physics_process(false); enemy.active_ai=false
	sample.jelly_fx.set_process(false)
	var victim: CharacterBody3D=sample.enemies[0]
	var center: Vector2=sample.meadow.landmarks.grove
	victim.position=Vector3(center.x,sample.floor_height(center)+.06,center.y+1.)
	for i in 4: await physics_frame
	sample.scripted_fire=true
	sample.fire_at(victim.position+Vector3.UP*.8)
	sample.scripted_fire=false
	for i in 100:
		await physics_frame
		if sample.landed_hits>0: break
	verify(sample.landed_hits==1 and victim.hp==11. and Engine.time_scale==1.,"native projectile damage and uninterrupted ordinary fire remain intact")
	verify(sample.jelly_fx.bits.size()==4,"actual bullet impact emits two primary sugar pieces and two tiny flakes")
	verify(sample.jelly_fx.bits.filter(func(bit: Dictionary) -> bool: return bit.main).size()==2,"only the two main fragments are bounce candidates")
	verify(victim.visual.material_override==victim.soft_ink and victim.soft_ink.get_shader_parameter("dent")>.07,"actual native contact triggers local soft-body deformation")
	verify(victim.contact_uv.x>=.1 and victim.contact_uv.y>=.1,"body dent is registered at a bounded texture contact coordinate")
	var capsule_before: Vector3=victim.hit_area.position
	# Freeze the world to compare only the GPU-visible local deformation.
	sample.set_process(false); sample.set_physics_process(false)
	var soft: Image=await snapshot()
	soft.save_png("res://docs/captures/world_restart/elastic32_contact.png")
	victim.soft_ink.set_shader_parameter("dent",0.)
	var plain: Image=await snapshot()
	verify(changed(soft,plain,Rect2i(Vector2i.ZERO,soft.get_size()))>5,"local dent changes actual GPU pixels rather than only shader bookkeeping")
	victim._render_legacy(0.)
	verify(victim.hit_area.position==capsule_before,"local silhouette deformation does not displace the native hurt capsule")
	# An off-centre hit should give the tuft its own delayed response.
	victim.impulse=Vector2.ZERO
	victim.tuft=0.; victim.tuft_velocity=0.
	victim.impact_contact=victim.global_position+Vector3(-.4,.65,0)
	victim.receive_hit(1.,Vector3.RIGHT)
	for i in 12: victim._physics_process(1./120.)
	verify(absf(victim.tuft)>.015 and absf(victim.soft_ink.get_shader_parameter("head_lag"))>.015,"upper tuft follows with a delayed damped response")
	for i in 150: victim._physics_process(1./120.)
	verify(absf(victim.tuft)<.002 and absf(victim.squeeze)<.002,"both soft responses settle without permanent distortion")
	victim.hopping=true; victim.hop_clock=sample.Profile.HOP_TIME-.004
	var before_landing: int=victim.landing_count
	victim._physics_process(1./120.)
	verify(victim.landing_count==before_landing+1 and victim.squeeze>.06,"a real hop-to-ground transition adds a light landing rebound")
	# Remove the second hit's effects so the landing lifecycle checks one impact.
	sample.jelly_fx.clear()
	sample.jelly_fx.break_sugar(victim.position+Vector3.UP*.8,Vector3.RIGHT)
	for i in 20: sample.jelly_fx._process(1./120.)
	var flying: Image=await snapshot()
	flying.save_png("res://docs/captures/world_restart/elastic32_sugar_air.png")
	for i in 120:
		sample.jelly_fx._process(1./120.)
		if sample.jelly_fx.settlements==4: break
	verify(sample.jelly_fx.bounces==2,"each primary sugar piece bounces once and tiny flakes do not bounce")
	verify(sample.jelly_fx.settlements==4,"all four sugar fragments reach a settled ground state")
	var on_ground := true
	for bit in sample.jelly_fx.bits:
		on_ground=on_ground and absf(bit.at.y-sample.floor_height(Vector2(bit.at.x,bit.at.z))-.028)<.001
	verify(on_ground and sample.jelly_fx.bits.size()>0,"settled sugar rests on real terrain and persists briefly")
	var ground: Image=await snapshot()
	ground.save_png("res://docs/captures/world_restart/elastic32_sugar_ground.png")
	for i in 150: sample.jelly_fx._process(1./120.)
	verify(sample.jelly_fx.bits.is_empty(),"settled sugar automatically fades and expires")
	sample.jelly_fx.clear()
	for i in 100: sample.jelly_fx.break_sugar(victim.position+Vector3.UP*.8,Vector3.RIGHT)
	verify(sample.jelly_fx.bits.size()==sample.jelly_fx.MAX_BITS,"rapid-fire fragments obey the fixed 64-piece budget")
	sample._reset_impact_state()
	verify(sample.jelly_fx.bits.is_empty() and sample.jelly_fx.sugar.multimesh.visible_instance_count==0,"restart removes physical fragments and their rendered instances")
	sample.cup_contact_active=true
	sample.sugar_contact(victim.position,Vector3.RIGHT)
	verify(sample.jelly_fx.bits.is_empty(),"goose body contact cannot manufacture phantom broken bullets")
	sample.cup_contact_active=false
	sample.legacy_contact_art(victim.position+Vector3.UP*.5,Vector3.RIGHT,false)
	verify(sample.jelly_fx.bits.size()==4,"wall and corpse contact effects also use world-space sugar")
	sample._unhandled_input(event(KEY_HOME))
	verify(not sample.enhanced_feedback and sample.jelly_fx.bits.is_empty(),"Home switches to the complete 31 feedback comparison with a clean round")
	verify(sample.enemies[0].visual.material_override==null,"31 comparison removes local deformation shader")
	sample._unhandled_input(event(KEY_HOME))
	verify(sample.enhanced_feedback and not sample.ordinary_hitstop,"Home restores new soft-body and fragment feedback without ordinary global freeze")
	sample._unhandled_input(event(KEY_INSERT))
	verify(not sample.material_feedback and sample.ordinary_hitstop,"older full feedback comparison remains available")
	sample.queue_free(); await process_frame
	verify(Engine.time_scale==1.,"leaving the scene restores global time")
	print("ELASTIC32 ",checks," checks; failures=",failures.size())
	quit(0 if failures.is_empty() else 1)
