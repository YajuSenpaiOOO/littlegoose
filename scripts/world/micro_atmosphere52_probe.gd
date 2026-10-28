extends "res://scripts/world/woodland46_probe.gd"
class AirSample:
	extends "res://scripts/world/world52.gd"
	func _hero_script() -> Script: return LivingActor
	func fire_input_held() -> bool: return false

func shot52(name: String) -> Image:
	var image: Image=await snapshot()
	image.save_png("res://docs/captures/world_restart/air52_"+name+".png")
	return image

func run() -> void:
	var sample: Node3D=AirSample.new()
	root.add_child(sample)
	while not is_instance_valid(sample.sun_dust52): await physics_frame
	for i in 40: await physics_frame
	sample.hero.controls_enabled=false
	sample.label.get_parent().hide()
	var light: Node3D=sample.porch49
	var dust: Node3D=sample.sun_dust52
	verify(RenderingServer.get_current_rendering_method()=="gl_compatibility","Compatibility retained")
	verify(dust.motes.size()==96 and dust.batch.multimesh.instance_count==96,"dust uses a fixed 96-instance pool")
	verify(not light.warm_light.shadow_enabled and is_equal_approx(light.warm_light.omni_range,1.45),"one small fill light adds no shadow map")
	verify(not light.has_node("DoorstepVolume") and sample.garden.material_stage==1,"intact stairs and original stones retained")
	var shadow_at := Vector2.ZERO
	var minimum := INF
	for tree in sample.trees:
		var at := Vector2(tree.root.position.x+1.4,tree.root.position.z+1.2)
		if at.distance_to(Vector2(-4.7,-2.8))<16. or sample.meadow.route_distance(at)>3.3: continue
		var field: Color=light.sample_field(at)
		var luma := field.r*.2126+field.g*.7152+field.b*.0722
		if luma<minimum: minimum=luma; shadow_at=at
	sample._teleport15(shadow_at)
	for i in 80: await physics_frame
	for enemy in sample.enemies: enemy.active_ai=false
	paused=true
	dust.set_enabled(false)
	light.set_fill(false)
	var baseline: Image=await shot52("shade_off")
	var before_tint: Color=sample.hero.visual.modulate
	var camera_before: Transform3D=sample.camera.transform
	var hero_before: Vector3=sample.hero.position
	light.set_fill(true)
	var warmed: Image=await shot52("shade_fill")
	verify(light.fill_strength>.5 and light.warm_light.light_energy<=.1201,"shade activates a bounded weak fill")
	verify(sample.hero.visual.modulate.r>before_tint.r and sample.hero.visual.modulate.r/sample.hero.visual.modulate.b>before_tint.r/before_tint.b,"fill gently lifts and warms the actor")
	verify(sample.camera.transform==camera_before and sample.hero.position==hero_before,"fill comparison preserves framing and actor position")
	var area := Rect2i(Vector2i.ZERO,warmed.get_size())
	verify(changed(baseline,warmed,area)>50,"gentle fill visibly changes the actual rendered image")
	light.set_fill(false)
	var restored: Image=await snapshot()
	verify(changed(restored,baseline,area)<100,"fill switch restores without residual light")
	light.set_fill(true)
	paused=false
	var opening: Array=light.woodland_data.openings[2].at
	sample._teleport15(Vector2(opening[0],opening[1]))
	dust.set_enabled(true)
	dust._refresh()
	for i in 120: await physics_frame
	paused=true
	light.set_fill(true)
	verify(light.desired_fill()<.12,"fill nearly disappears in a sunlight opening")
	verify(dust.visible_motes>3,"sunlit dust has visible motes near the player")
	dust.set_enabled(false)
	var clear: Image=await shot52("sun_no_dust")
	dust.set_enabled(true)
	var airy: Image=await shot52("sun_dust")
	verify(changed(clear,airy,area)>10,"dust appears in the rendered sunlight view")
	dust.update_motes(2.)
	var drifting: Image=await shot52("sun_drift")
	verify(changed(drifting,airy,area)>10,"motes drift over time rather than forming static screen specks")
	paused=false
	sample._travel_region("home")
	for i in 80: await physics_frame
	await shot52("home")
	sample._teleport15(Vector2(-4.6,.7))
	sample.hero.controls_enabled=true
	verify(await walk_to(sample,Vector2(-4.6,-2.6)),"courtyard remains walkable")
	sample.hero.controls_enabled=false
	sample.start_combat()
	for enemy in sample.enemies: enemy.active_ai=false
	for i in 12: await physics_frame
	verify(sample.enemies.size()==1 and sample.round_index==0,"first-wave combat retained")
	sample.hurt_flash=.2
	light._update_actor()
	verify(sample.hero.visual.modulate.r>sample.hero.visual.modulate.g*1.8,"fill preserves red damage feedback")
	var silhouette: MeshInstance3D=sample.hero.get_node("GroundedActorSilhouette")
	verify(not sample.hero_contact.visible and silhouette.visible and silhouette.enabled,"existing silhouette shadow remains active without restoring the replaced ellipse")
	var output := FileAccess.open("res://docs/air52-validation.json",FileAccess.WRITE)
	output.store_string(JSON.stringify({"checks":checks,"failures":failures,"pool":dust.motes.size(),"visible_motes":dust.visible_motes,"shade_at":[shadow_at.x,shadow_at.y]},"\t"))
	print("AIR52 ",checks," checks; failures=",failures.size())
	quit(0 if failures.is_empty() else 1)
