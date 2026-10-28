extends "res://scripts/ground_lab_probe.gd"

func run() -> void:
	var sample: Node3D=load("res://scenes/world/world31.tscn").instantiate()
	root.add_child(sample)
	while not sample.material_ready: await physics_frame
	sample.start_combat()
	sample.set_cup_phone(false)
	sample.hero.controls_enabled=false
	for enemy in sample.enemies: enemy.set_physics_process(false)
	verify(not sample.ordinary_hitstop and sample.material_feedback,"new feedback defaults to uninterrupted ordinary fire")
	var victim: CharacterBody3D=sample.enemies[0]
	var center: Vector2=sample.meadow.landmarks.grove
	victim.position=Vector3(center.x,sample.floor_height(center)+.06,center.y+1.)
	for i in 4: await physics_frame
	sample.fire_at(victim.position+Vector3.UP*.8)
	for i in 100:
		await physics_frame
		if sample.landed_hits>0: break
	verify(sample.landed_hits==1 and victim.hp==11.,"actual native projectile still delivers exactly one damage")
	verify(Engine.time_scale==1. and sample.stop_until==0.,"ordinary native hit does not pause the world")
	verify(victim.squeeze>.1 and sample.jelly_fx.drops.size()==2,"actual contact drives the body spring and two world-space droplets")
	var hurt_center: Vector3=victim.hit_area.position
	victim._render_legacy(0.)
	verify(victim.visual.scale.y<.9 and victim.visual.scale.x>1.08,"hit visibly compresses the foot-anchored silhouette")
	verify(victim.hit_area.position==hurt_center,"cosmetic squash does not move the aiming capsule")
	var hit: Image=await snapshot()
	hit.save_png("res://docs/captures/world_restart/material31_hit.png")
	var lowest: float=victim.squeeze
	for i in 55:
		victim._physics_process(1./120.)
		lowest=minf(lowest,victim.squeeze)
	verify(lowest<-.01 and absf(victim.squeeze)<.01,"body rebounds past rest then settles instead of sticking squashed")
	for i in 80:
		await physics_frame
		if sample.jelly_fx.landed>=2: break
	verify(sample.jelly_fx.landed==2 and sample.jelly_fx.drops.is_empty(),"both emitted droplets hit the actual terrain")
	verify(sample.jelly_fx.marks.size()==2,"droplet impact leaves bounded temporary ground residue")
	var grounded := true
	for mark in sample.jelly_fx.marks:
		grounded=grounded and absf(mark.at.y-sample.floor_height(Vector2(mark.at.x,mark.at.z))-.033)<.001
	verify(grounded,"residue elevation follows terrain instead of a global flat plane")
	var marks: Image=await snapshot()
	marks.save_png("res://docs/captures/world_restart/material31_residue.png")
	verify(sample.jelly_fx.hit_clip.data.size()>10000 and sample.jelly_fx.voice_index>=2,"contact and landing use separate nonempty audio voices")
	verify(sample.jelly_fx.voices[0].stream.stereo,"contact confirmation uses the new gently panned stereo clip")
	var label_length: int=sample.label.text.length()
	for i in 100: sample._status()
	verify(sample.label.text.length()==label_length,"debug hint does not accumulate or grow on repeated HUD refreshes")
	# At high buff fire rates, cosmetic instance count is bounded and marks expire.
	for i in 80: sample.jelly_fx.burst(victim.position+Vector3.UP*.6,Vector3.RIGHT,false)
	verify(sample.jelly_fx.drops.size()==sample.jelly_fx.MAX_DROPS,"particle count remains capped during a large contact burst")
	sample.jelly_fx._process(1.5)
	verify(sample.jelly_fx.marks.size()<=sample.jelly_fx.MAX_MARKS,"ground residue respects a fixed instance budget")
	sample.jelly_fx._process(3.)
	verify(sample.jelly_fx.marks.is_empty(),"all temporary stains expire rather than accumulate across the map")
	sample._reset_impact_state(); sample.combo=9
	sample.notify_hit()
	verify(is_equal_approx(Engine.time_scale,.05) and is_equal_approx(sample.stop_duration,.045),"tenth-hit milestone retains its stronger legacy beat")
	sample._reset_impact_state()
	victim.hp=1.; victim.receive_hit(1.,Vector3.RIGHT)
	verify(victim.dead and sample.punch==.32 and is_equal_approx(Engine.time_scale,.05),"normal kill retains original hitstop and small lens punch")
	verify(sample.kick_left>0.,"kill adds a bounded directional camera accent")
	sample.start_combat()
	verify(sample.jelly_fx.drops.is_empty() and sample.jelly_fx.marks.is_empty() and sample.kick_left==0.,"restart removes flying particles, residue and directional kick")
	sample._unhandled_input(event(KEY_INSERT))
	verify(not sample.material_feedback and sample.ordinary_hitstop,"comparison toggles original juice, pose and ordinary global hitstop together")
	sample._unhandled_input(event(KEY_INSERT))
	verify(sample.material_feedback and not sample.ordinary_hitstop,"comparison returns to the new uninterrupted feedback")
	sample.queue_free(); await process_frame
	verify(Engine.time_scale==1.,"leaving the test scene restores global time")
	print("MATERIAL31 ",checks," checks; failures=",failures.size())
	quit(0 if failures.is_empty() else 1)
