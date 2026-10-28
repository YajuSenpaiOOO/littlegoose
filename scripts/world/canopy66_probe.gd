extends "res://scripts/world/air52_performance_probe.gd"
class CanopySample:
	extends "res://scripts/world/world66.gd"
	func _hero_script() -> Script: return LivingActor
	func fire_input_held() -> bool: return false

func shot(tag: String) -> Image:
	var frame := await snapshot()
	frame.save_png("res://docs/captures/world_restart/canopy66_"+tag+".png")
	return frame

func run() -> void:
	var sample := CanopySample.new()
	root.add_child(sample)
	while not is_instance_valid(sample.frames66): await physics_frame
	for i in 35: await physics_frame
	verify(sample.bridge59.moving and sample.bridge59.sparkling and sample.landmark62.root_shapes65>2,"living water and willow collision preserved")
	verify(RenderingServer.get_current_rendering_method()=="gl_compatibility" and is_equal_approx(sample.camera.rotation_degrees.x,-25.),"Compatibility and approved camera preserved")
	var target: Dictionary={}
	for tree in sample.trees:
		var at: Vector3=tree.root.global_position
		if tree.height<9. and at.distance_to(sample.hero.global_position)<16. and at.x<sample.hero.global_position.x-3.:
			target=tree
			break
	verify(not target.is_empty(),"a real foreground tree is available for the visual trial")
	var at: Vector3=target.root.global_position
	sample._teleport15(Vector2(at.x,at.z-2.8))
	for i in 35: await physics_frame
	sample.hero.controls_enabled=false
	sample.time55.preview_at(12.)
	sample.time55.visual_hour=12.; sample.time55.apply_look()
	sample.label.get_parent().hide()
	sample.frames66.panel.hide()
	paused=true
	var canopy: RefCounted=sample.canopy66
	sample.fade_enabled=false
	for i in 22: canopy.update(.07)
	canopy.sync_materials()
	var solid := await shot("solid")
	sample.fade_enabled=true
	for i in 22: canopy.update(.07)
	canopy.sync_materials()
	var entry: Dictionary=canopy.entries[target.visual.get_instance_id()]
	verify(entry.target and entry.strength>.99,"a foreground crown overlapping the body opens fully")
	verify(is_equal_approx(target.visual.material_override.get_shader_parameter("fade"),1.),"whole-tree opacity stays intact in local mode")
	var opened := await shot("local")
	var image_scale := Vector2(solid.get_size())/sample.get_viewport().get_visible_rect().size
	var center: Vector2=canopy.center_pixels*image_scale
	var radius: Vector2=canopy.radius_pixels*image_scale
	var inside := 0
	var outside := 0
	for y in range(0,solid.get_height(),3):
		for x in range(0,solid.get_width(),3):
			var delta_color := solid.get_pixel(x,y)-opened.get_pixel(x,y)
			if absf(delta_color.r)+absf(delta_color.g)+absf(delta_color.b)<.06: continue
			if ((Vector2(x,y)-center)/(radius+Vector2.ONE*18.)).length_squared()<1.: inside+=1
			else: outside+=1
	verify(inside>40,"the soft opening produces a visible change around the hero")
	verify(outside<maxi(30,inside/8),"the surrounding canopy stays visually solid outside the local window")
	var key: int=target.visual.get_instance_id()
	for step in 30:
		sample._teleport15(Vector2(at.x+(step+1)*.5,at.z-2.8))
		canopy.update(.07)
		if not canopy.entries[key].target: break
	verify(not canopy.entries[key].target and canopy.entries[key].strength>.9,"leaving a crown retains a short exit buffer")
	for i in 22: canopy.update(.07)
	canopy.sync_materials()
	verify(canopy.entries[key].strength<.001,"the old crown restores after the exit buffer")
	sample._teleport15(Vector2(at.x,at.z-2.8))
	canopy.set_local(false)
	for i in 20: sample._update_forest_occlusion(.07)
	sample._update_tree_blending()
	await shot("legacy")
	verify(target.visual.material_override.get_shader_parameter("fade")<.999,"legacy whole-tree fade remains available for comparison")
	canopy.set_local(true)
	for i in 22: canopy.update(.07)
	canopy.sync_materials()
	sample.frames66.panel.show()
	var now := Time.get_ticks_usec()/1000000.
	sample.frames66.clear_samples()
	sample.frames66.add_sample(now-.4,16.7)
	sample.frames66.add_sample(now-.2,58.)
	sample.frames66.refresh(now)
	verify(sample.frames66.slow_count==1 and is_equal_approx(sample.frames66.worst_ms,58.),"frame display retains a brief stall and identifies its location")
	verify(sample.frames66.panel.is_visible_in_tree() and not sample.label.get_parent().visible,"frame monitor remains visible with the normal guide hidden")
	await shot("monitor")
	sample.frames66.clear_samples(); sample.frames66.refresh(now)
	verify(sample.frames66.slow_count==0 and sample.frames66.worst_ms==0.,"clearing the frame monitor resets the observation window")
	paused=false
	sample.frames66.focused=true
	sample._travel_region("home")
	for i in 40: await physics_frame
	sample.hero.controls_enabled=true
	var performance := await record(sample,360,true)
	sample.hero.controls_enabled=false
	sample.go_roots64()
	sample.frames66.clear_samples()
	for i in 90: await physics_frame
	await shot("live_monitor")
	var perf_file := FileAccess.open("res://docs/canopy66-performance.json",FileAccess.WRITE)
	perf_file.store_string(JSON.stringify(performance,"\t"))
	var file := FileAccess.open("res://docs/canopy66-validation.json",FileAccess.WRITE)
	file.store_string(JSON.stringify({"checks":checks,"failures":failures,"changed_inside":inside,"changed_outside":outside,"tested_tree":str(at)},"\t"))
	print("CANOPY66 ",checks," checks; failures=",failures.size()," performance=",JSON.stringify(performance))
	quit(0 if failures.is_empty() else 1)
