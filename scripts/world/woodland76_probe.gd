extends "res://scripts/world/depth75_probe.gd"

class ForestSample:
	extends "res://scripts/world/world76.gd"
	var permit_combat76 := false
	func _hero_script() -> Script: return LivingActor
	func fire_input_held() -> bool: return false
	func hurt_player(_damage: float,_from: Vector2) -> void: pass
	func start_combat(reposition := true) -> void:
		if permit_combat76: super.start_combat(reposition)

func shot76(sample: Node3D,at: Vector2,tag: String) -> void:
	sample.hero.controls_enabled=false;sample._teleport15(at);await settle72(35)
	var frame := await snapshot();frame.save_png("res://docs/captures/world_restart/woodland76_"+tag+".png")

func advance76(sample: Node3D,frames: int) -> void:
	for i in frames:
		sample._update_forest_occlusion(.02);sample._sync_root_fades15();sample._update_tree_blending()

func fade_checks76(sample: Node3D) -> void:
	var modern: RefCounted=sample.whole67
	var legacy := preload("res://scripts/art/whole_tree_fade67.gd").new();legacy.world=sample
	legacy.masks67=modern.masks67
	var willow: Sprite3D=sample.landmark_tree.visual
	var old_miss := false;var reproducer := Vector2.INF
	var original_distance: float=sample.camera_distance
	sample.hero.controls_enabled=false
	# Search the real north-of-willow approach and the supported wheel distances.
	for distance in [original_distance,13.,18.,26.]:
		if old_miss: break
		sample.camera_distance=distance
		for dz in [-9.,-12.,-15.,-18.]:
			if old_miss: break
			for dx in [-6.,-2.,2.,6.]:
				var at: Vector2=sample.meadow.landmarks.junction+Vector2(dx,dz)
				sample._teleport15(at);modern.update(.08)
				legacy.center_pixels=modern.center_pixels;legacy.radius_pixels=modern.radius_pixels
				legacy._scan()
				var key := willow.get_instance_id()
				if modern.entries[key].target and not legacy.entries[key].target:
					old_miss=true;reproducer=at;break
	verify(old_miss,"real willow approach reproduces a legacy miss covered by the new controller")
	if old_miss:
		print("FADE76_REPRO at=",reproducer," distance=",sample.camera_distance," legacy=",legacy.screen_bounds(willow)," clipped=",modern.screen_bounds(willow))
		paused=true;legacy.reset_fades();sample.whole67=legacy;sample.fade_enabled=true;advance76(sample,65)
		var before := await snapshot();before.save_png("res://docs/captures/world_restart/woodland76_willow_before.png")
		modern.reset_fades();sample.whole67=modern;advance76(sample,65)
		var after := await snapshot();after.save_png("res://docs/captures/world_restart/woodland76_willow_after.png")
		verify(modern.entries[willow.get_instance_id()].opacity<.001,"blocking willow fully fades rather than retaining a screen-sized veil")
		verify(changed(before,after,Rect2i(Vector2i.ZERO,after.get_size()))>10000,"near-willow correction visibly changes rendered pixels")
		paused=false
	# Exercise the same near-plane failure with an ordinary tree's real texture.
	sample.camera_distance=original_distance;sample._teleport15(sample.meadow.landmarks.junction+Vector2(3,-13))
	await settle72(5)
	paused=true
	var ordinary: Dictionary={}
	for tree in sample.trees:
		if tree.height<9.: ordinary=tree;break
	var old_pose: Transform3D=ordinary.root.global_transform
	ordinary.root.global_position=sample.camera.global_position-sample.camera.global_basis.z*1.8-Vector3.UP*3.
	ordinary.root.force_update_transform();ordinary.visual.force_update_transform()
	modern.update(.08)
	var bounds: Rect2=modern.screen_bounds(ordinary.visual)
	verify(bounds.has_area() and bounds.intersection(sample.get_viewport().get_visible_rect()).has_area(),"near-plane-straddling ordinary tree retains a valid projected footprint")
	advance76(sample,65)
	verify(modern.entries[ordinary.visual.get_instance_id()].opacity<.001,"ordinary near-camera crown uses the same whole-tree protection")
	ordinary.root.global_transform=old_pose;paused=false
	sample.camera_distance=original_distance
	sample._teleport15(sample.meadow.landmarks.grove+Vector2(0,2));await settle72()
	paused=true;advance76(sample,70)
	verify(modern.entries[willow.get_instance_id()].opacity>.999,"distant willow restores outside the foreground obstruction")
	sample.set_review72(true);modern._scan()
	verify(modern.candidate_count==0,"overview does not hide the landmark for occupying a large screen area")
	sample.set_review72(false);paused=false

func alive76(sample: Node3D) -> Array:
	var found := []
	for enemy in sample.enemies:
		if is_instance_valid(enemy) and not enemy.dead: found.append(enemy)
	return found

func clear_wave76(sample: Node3D) -> void:
	var deadline := Time.get_ticks_msec()+28000
	var shot_clock := 0.
	while not sample.wave_reward_pending and sample.wave_state=="fighting" and Time.get_ticks_msec()<deadline:
		var targets := alive76(sample)
		if not targets.is_empty():
			var enemy: CharacterBody3D=targets[0]
			var toward := Vector2(enemy.position.x-sample.hero.position.x,enemy.position.z-sample.hero.position.z)
			sample.hero.wish=toward.normalized() if toward.length()>3.8 else Vector2.ZERO
			shot_clock+=sample.get_physics_process_delta_time()
			if shot_clock>=sample.attack_cooldown():
				shot_clock=0.;sample.fire_at(enemy.position+Vector3.UP*.70)
		await physics_frame
	sample.hero.wish=Vector2.ZERO

func choose76(sample: Node3D,id: String) -> bool:
	var deadline := Time.get_ticks_msec()+3500
	while not sample.draft_open and Time.get_ticks_msec()<deadline: await process_frame
	await create_timer(.4).timeout
	for i in sample.draft_choices.size():
		if sample.draft_choices[i].id==id: return sample.choose_buff(i)
	return false

func run() -> void:
	var sample := ForestSample.new();root.add_child(sample)
	while not is_instance_valid(sample.wall76): await physics_frame
	await settle72()
	var s: RefCounted=sample.meadow
	var g: Vector2=s.landmarks.grove
	var old := preload("res://scripts/world/world_surface75.gd").new()
	verify(s.world_bounds==old.world_bounds,"world bounds stay unchanged while the woodland opening grows")
	verify(s.FIELD_RADII76==Vector2(20,15) and s.ROOT_BUFFER76==Vector2(23,18),"40 by 30m clearing has a separate 3m root buffer")
	var flat := true
	for i in 24:
		var a := TAU*i/24.
		var at: Vector2=g+Vector2(cos(a),sin(a))*s.FIELD_RADII76*.96
		flat=flat and absf(sample.floor_height(at)-2.1)<.06
	verify(flat,"enlarged playable ellipse stays on the continuous main forest shelf")
	var intrusion := 0
	for tree in sample.trees:
		var at := Vector2(tree.root.position.x,tree.root.position.z)
		if ((at-g)/s.ROOT_BUFFER76).length()<1.: intrusion+=1
	verify(intrusion==0,"ordinary tree roots stay out of both the clearing and its buffer")
	verify(sample.navigation.grid.region.size==Vector2i(85,85),"enemy navigation grows to 63 by 63m around the entire encounter")
	var edge_margin := true
	for axis in [Vector2.LEFT,Vector2.RIGHT,Vector2.UP,Vector2.DOWN]:
		var at: Vector2=g+axis*30.
		var cell := Vector2i(((at-sample.navigation.origin)/sample.navigation.CELL).round())
		edge_margin=edge_margin and sample.navigation.grid.region.grow(-1).has_point(cell)
	verify(edge_margin,"navigation covers the 29m exit radius with a full-cell safety margin")
	verify(sample._encounter_leave_radius37()==29. and sample._wave_return_radius40()==27.,"encounter exit and wave return use the larger region")
	verify(sample.wall76.thickness>=.6 and sample.wall76.block_count76>=7,"sample wall has solid thickness and joined block modules")
	verify(sample.ground_materials[0].get_shader_parameter("paint")!=null,"accepted painted turf texture is bound to the sample material")
	for name in ["home_to_junction","junction_to_grove","junction_to_station","junction_to_shore","home_to_landing","woodland_return72"]:
		verify(await walk_route72(sample,name),"actual character traverses "+name)
	verify(await walk_route72(sample,"junction_to_grove",true),"woodland entry returns downhill without the wall blocking the route")
	sample.hero.controls_enabled=true;sample._teleport15(g+Vector2(-18,0));await settle72(8)
	var cross_ok := true
	for dx in [-9.,0.,9.,18.]: cross_ok=cross_ok and await walk_to(sample,g+Vector2(dx,0))
	verify(cross_ok,"actual hero crosses 36m of usable clearing width")
	sample._teleport15(g+Vector2(0,-13.));await settle72(8)
	var deep_ok := true
	for dz in [-4.,5.,13.]: deep_ok=deep_ok and await walk_to(sample,g+Vector2(0,dz))
	verify(deep_ok,"actual hero crosses 26m of usable clearing depth")
	await fade_checks76(sample)
	sample.label.get_parent().hide();sample.frames66.panel.hide()
	await shot76(sample,Vector2(-26.,-32.3),"entry_sample")
	paused=true;sample.set_art_sample76(false)
	var plain := await snapshot();sample.set_art_sample76(true)
	var painted := await snapshot()
	verify(changed(plain,painted,Rect2i(Vector2i.ZERO,painted.get_size()))>5000,"painted turf, ragged path and solid wall visibly differ from structure mode")
	painted.save_png("res://docs/captures/world_restart/woodland76_material_sample.png")
	paused=false
	sample.time55.preview_at(22.);sample.time55.visual_hour=22.;sample.time55.apply_look();await settle72(30)
	var night := await snapshot();night.save_png("res://docs/captures/world_restart/woodland76_sample_night.png")
	sample.time55.preview_at(12.);sample.time55.visual_hour=12.;sample.time55.apply_look()
	await shot76(sample,g+Vector2(0,4),"field")
	sample.set_review72(true);await settle72()
	var overview := await snapshot();overview.save_png("res://docs/captures/world_restart/woodland76_overview.png")
	sample.set_review72(false)
	sample.label.get_parent().show();sample.frames66.panel.show()
	sample.permit_combat76=true;sample.start_combat();sample.player_hp=80.;await settle72(60)
	verify(alive76(sample).size()==1 and alive76(sample)[0]._engagement_radius33()==30.,"new enemies use the expanded engagement range")
	var perf := await record(sample,240,false)
	var native_total_hits := 0
	for wave in 3:
		await clear_wave76(sample)
		verify(sample.defeated_count==[1,3,6][wave] and sample.round_index==wave,"live AI and native projectiles complete wave "+str(wave+1))
		native_total_hits=sample.landed_hits
		var id: String=["eye_exercise","cup_phone","slingshot"][wave]
		verify(await choose76(sample,id),"wave reward remains selectable: "+id)
	verify(native_total_hits>=72,"all six enemies were defeated through native projectile hits")
	verify(sample.buffs.levels.size()==3 and sample.round_index==0,"three-wave reward flow returns to a fresh encounter")
	var report := {"checks":checks,"failures":failures,"combat_sample":perf,"field_size":[40,30],"navigation_size":[63,63]}
	var file := FileAccess.open("res://docs/woodland76-validation.json",FileAccess.WRITE);file.store_string(JSON.stringify(report,"\t"))
	print("WOODLAND76 ",JSON.stringify(report))
	quit(0 if failures.is_empty() else 1)
