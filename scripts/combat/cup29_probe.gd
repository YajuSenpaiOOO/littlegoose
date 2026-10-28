extends "res://scripts/ground_lab_probe.gd"
func run() -> void:
	var sample: Node3D=load("res://scenes/world/world29.tscn").instantiate()
	root.add_child(sample)
	while not is_instance_valid(sample.guide_overlay): await physics_frame
	sample.start_combat()
	sample.set_physics_process(false)
	sample.hero.controls_enabled=false
	sample.hero.set_physics_process(false)
	for enemy in sample.enemies: enemy.set_physics_process(false)
	for i in 4: await physics_frame
	var goose: Node3D=sample.goose
	verify(goose.cup_phone and sample.cup_phone_enabled,"telephone is enabled in the preview")
	verify(not sample.label.visible and not sample.perf_label.visible and sample.cup_chip.visible,"quiet HUD hides debug panels and retains the small buff chip")
	var at: Vector3=sample.hero.position+Vector3(4.2,.85,0)
	goose.last_shot_direction=Vector3.LEFT
	goose.update_follow(0.,sample.hero.position+Vector3(2,.85,0),true)
	verify(goose.last_shot_direction.x>.99,"a fresh snapped flight starts toward the new cursor rather than retaining an old heading")
	for i in 180: goose.update_follow(1./60.,at)
	verify(goose.offset_xz.length()>3.8,"telephone flies well outside the old 1.35m familiar radius")
	for i in 180: goose.update_follow(1./60.,sample.hero.position+Vector3(40,.85,0))
	verify(goose.offset_xz.length()<=110./sample.Profile.PPM+.001,"legacy 110-world-pixel leash is preserved")
	at=sample.hero.position+Vector3(2,.85,-1.5)
	at.y=sample.floor_height(Vector2(at.x,at.z))+.85
	for i in 180: goose.update_follow(1./60.,at)
	var direction: Vector3=goose.last_shot_direction
	for i in 30: goose.update_follow(1./60.,at)
	verify(goose.last_shot_direction.dot(direction)>.99,"arriving at the cursor keeps a stable firing heading")
	var resolved: Vector3=sample.resolved_fire_target(goose.muzzle(),goose.muzzle())
	verify(resolved.is_finite() and is_equal_approx(resolved.distance_to(goose.muzzle()),3.),"coincident cursor and muzzle retain a finite three-meter shot direction")
	var hero_before: Vector3=sample.hero.position
	goose.recoil(Vector3.RIGHT)
	verify(goose.spring_velocity.x<0. and sample.hero.position==hero_before,"recoil pushes the familiar spring without moving hero")
	var victim: CharacterBody3D=sample.enemies[0]
	var center: Vector3=sample.hero.position
	victim.position=Vector3(center.x+1.6,0,center.z-4.)
	victim.position.y=sample.floor_height(Vector2(victim.position.x,victim.position.z))+.04
	goose.position=Vector3(center.x+3.5,sample.floor_height(Vector2(center.x+3.5,center.z))+.43,center.z)
	goose.offset_xz=Vector2(goose.position.x-center.x,goose.position.z-center.z)
	goose.reset_physics_interpolation()
	for i in 3: await physics_frame
	var hp: float=victim.hp
	sample.fire_at(victim.position+Vector3.UP*.8)
	var shot: Dictionary=sample.shots[-1]
	verify(shot.node.position.distance_to(sample.projectile_origin())<.28 and shot.node.position.distance_to(sample.hero.position)>2.,"detached familiar remains the actual projectile source")
	for i in 180:
		sample._step_shots(1./120.)
		if sample.landed_hits>0: break
	verify(victim.hp==hp-1.,"detached familiar hits via native 3D bullet collision")
	sample._clear_combat_shots()
	var other: CharacterBody3D=sample.enemies[1]
	var far: CharacterBody3D=sample.enemies[2]
	victim.position=Vector3(goose.position.x+.1,0,goose.position.z)
	victim.position.y=sample.floor_height(Vector2(victim.position.x,victim.position.z))+.04
	other.position=goose.position+Vector3(6,0,0)
	far.position=goose.position+Vector3(8,0,0)
	victim.hp=12.; other.hp=12.
	sample.combo=0
	var bullets_before: int=sample.landed_hits
	goose.clear_contact_state()
	goose.contact_clock=10.
	goose.step_contact()
	verify(victim.hp==11.5,"touch deals half ordinary projectile damage")
	goose.step_contact()
	goose.contact_clock=10.49
	goose.step_contact()
	verify(victim.hp==11.5,"same enemy cannot take contact damage again before half a second")
	goose.contact_clock=10.5
	goose.step_contact()
	verify(victim.hp==11.,"contact rearms after half a second")
	other.position=victim.position+Vector3(.2,0,0)
	goose.step_contact()
	verify(other.hp==11.5 and victim.hp==11.,"each enemy has an independent touch cooldown")
	verify(sample.combo==0 and sample.landed_hits==bullets_before,"touch does not farm bullet hit count or combo")
	sample.combat_paused=true
	goose.contact_clock=12.
	goose.step_contact()
	var paused: Vector3=goose.position
	goose.update_follow(1./60.,center+Vector3(-4,.85,0))
	verify(victim.hp==11. and goose.position.distance_to(paused)<.001,"pause freezes free flight and contact damage")
	sample.combat_paused=false
	sample.wave_state="cleared"
	goose.step_contact()
	verify(victim.hp==11.,"telephone cannot damage enemies after the round ends")
	for i in 3: await physics_frame
	var hit: Dictionary=sample.legacy_trace(goose.muzzle(),goose.muzzle()+Vector3.RIGHT)
	verify(not hit.is_empty() and hit.collider.has_meta("enemy"),"projectiles starting inside an enemy still detect its native hit body")
	sample._unhandled_input(event(KEY_BACKSPACE))
	verify(not goose.cup_phone,"Backspace returns to the original close-follow mode")
	for i in 180: goose.update_follow(1./60.,center+Vector3(4,.85,0))
	verify(goose.offset_xz.length()<=1.35+.001,"disabled telephone smoothly returns to the old familiar radius")
	sample._unhandled_input(event(KEY_BACKSPACE))
	sample.start_combat()
	verify(goose.cup_phone and goose.contact_next.is_empty(),"restart preserves the chosen buff and clears contact cooldowns")
	for enemy in sample.enemies: enemy.set_physics_process(false)
	sample._unhandled_input(event(KEY_F1))
	verify(sample.label.visible and sample.perf_label.visible,"F1 opens the full debug explanation")
	sample._unhandled_input(event(KEY_F1))
	verify(not sample.label.visible and not sample.perf_label.visible,"F1 returns to the quiet HUD")
	# A stable, uncluttered GPU frame showing the free goose and its paper thread.
	victim=sample.enemies[0]
	center=sample.hero.position
	victim.position=Vector3(center.x+4.,0,center.z-9.)
	victim.position.y=sample.floor_height(Vector2(victim.position.x,victim.position.z))+.04
	sample.enemies[2].position=Vector3(center.x-4.,0,center.z-6.)
	sample.enemies[2].position.y=sample.floor_height(Vector2(center.x-4.,center.z-6.))+.04
	var target: Vector3=victim.position+Vector3.UP*.7
	var pixel: Vector2=sample.camera.unproject_position(target)
	Input.warp_mouse(pixel*Vector2(root.size)/root.get_visible_rect().size)
	for i in 60:
		goose.update_follow(1./60.,target)
		await physics_frame
	sample.process_mode=Node.PROCESS_MODE_DISABLED
	sample.reticle.update_target(target)
	sample.guide_overlay.queue_redraw()
	var expected: Vector3=sample.resolved_fire_target(target,sample.reticle.line_origin)
	verify((sample.reticle.line_end-sample.reticle.line_origin).normalized().dot((expected-sample.reticle.line_origin).normalized())>.999,"polished guide retains the real muzzle firing direction")
	var image: Image=await snapshot()
	image.save_png("res://docs/captures/world_restart/cup29_paper_guide.png")
	sample.guide_overlay.hide()
	var hidden: Image=await snapshot()
	verify(changed(image,hidden,Rect2i(Vector2i.ZERO,image.get_size()))>20,"warm contrast-edged guide produces visible GPU pixels")
	print("CUP29 ",checks," checks; failures=",failures.size())
	quit(0 if failures.is_empty() else 1)
