extends "res://scripts/world/woodland46_probe.gd"
class PorchSample:
	extends "res://scripts/world/world49.gd"
	func _hero_script() -> Script: return LivingActor
	func fire_input_held() -> bool: return false

func run() -> void:
	var sample: Node3D=PorchSample.new()
	root.add_child(sample)
	while not is_instance_valid(sample.porch49): await physics_frame
	for i in 45: await physics_frame
	sample.hero.controls_enabled=false
	sample._travel_region("home")
	for i in 30: await physics_frame
	sample.label.get_parent().hide()
	var porch: Node3D=sample.porch49
	verify(RenderingServer.get_current_rendering_method()=="gl_compatibility","Compatibility renderer retained")
	verify(sample.garden.material_stage==1 and sample.atmosphere41.focus_level==2,"approved stones and focus retained")
	var camera_before: Transform3D=sample.camera.transform
	var hero_before: Vector3=sample.hero.position
	paused=true
	var shots: Array[Image]=[]
	for i in 3:
		porch.set_profile(i)
		for j in 2: await process_frame
		var shot: Image=await snapshot()
		shot.save_png("res://docs/captures/world_restart/porch49_home%d.png"%i)
		shots.append(shot)
		verify(sample.camera.transform==camera_before and sample.hero.position==hero_before,"comparison %d uses the identical camera and hero position"%i)
	verify(changed(shots[0],shots[1],Rect2i(Vector2i.ZERO,shots[0].get_size()))>5000,"architecture changes are visible in the frozen frame")
	verify(changed(shots[1],shots[2],Rect2i(Vector2i.ZERO,shots[0].get_size()))>80000,"canopy opening changes broad surface lighting")
	porch.set_profile(0)
	var restored: Image=await snapshot()
	verify(changed(shots[0],restored,Rect2i(Vector2i.ZERO,restored.get_size()))<100,"original comparison restores without residual shading")
	porch.set_profile(2)
	paused=false
	verify(not sample.house_art.material_override.shader.code.contains("if(step_piece49") and not porch.has_node("DoorstepVolume"),"painted stairs remain on the intact house sprite without cutouts or relief geometry")
	sample._teleport15(Vector2(.88,-2.7))
	for i in 30: await physics_frame
	(await snapshot()).save_png("res://docs/captures/world_restart/porch49_garden.png")
	sample._teleport15(Vector2(-4.7,-3.65))
	for i in 30: await physics_frame
	(await snapshot()).save_png("res://docs/captures/world_restart/porch49_door.png")
	sample._teleport15(Vector2(-4.6,.7))
	sample.hero.controls_enabled=true
	verify(await walk_to(sample,Vector2(-4.6,-2.6)),"courtyard route remains walkable")
	sample.hero.controls_enabled=false
	sample.start_combat()
	for enemy in sample.enemies: enemy.active_ai=false
	for i in 12: await physics_frame
	verify(sample.enemies.size()==1 and sample.round_index==0,"first-wave combat remains available")
	sample.hurt_flash=.2
	porch._update_actor()
	verify(sample.hero.visual.modulate.r>sample.hero.visual.modulate.g*1.8,"local actor tint preserves red damage feedback")
	var output := FileAccess.open("res://docs/porch49-validation.json",FileAccess.WRITE)
	output.store_string(JSON.stringify({"checks":checks,"failures":failures},"\t"))
	print("PORCH49 ",checks," checks; failures=",failures.size())
	quit(0 if failures.is_empty() else 1)
