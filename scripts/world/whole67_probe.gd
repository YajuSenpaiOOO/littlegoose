extends "res://scripts/world/air52_performance_probe.gd"
class Sample:
	extends "res://scripts/world/world67.gd"
	func _hero_script() -> Script: return LivingActor
	func fire_input_held() -> bool: return false

func advance(sample: Node3D,frames: int,delta: float=.02) -> void:
	for i in frames:
		sample._update_forest_occlusion(delta)
		sample._sync_root_fades15()
		sample._update_tree_blending()

func shot(tag: String) -> void:
	var frame := await snapshot()
	frame.save_png("res://docs/captures/world_restart/whole67_"+tag+".png")

func run() -> void:
	var sample := Sample.new()
	root.add_child(sample)
	while not is_instance_valid(sample.frames66): await physics_frame
	for i in 30: await physics_frame
	verify(sample.whole67.improved and sample.bridge59.moving and sample.bridge59.sparkling,"default is buffered whole-tree fade with living water")
	verify(sample.landmark62.root_shapes65>2 and RenderingServer.get_current_rendering_method()=="gl_compatibility","willow collision and Compatibility preserved")
	var target: Dictionary={}
	for tree in sample.trees:
		if tree.height<9. and tree.root.global_position.distance_to(sample.hero.global_position)<16. and tree.root.global_position.x<sample.hero.global_position.x-3.:
			target=tree; break
	var at: Vector3=target.root.global_position
	sample._teleport15(Vector2(at.x,at.z-2.8))
	sample.hero.controls_enabled=false
	for i in 20: await physics_frame
	sample.time55.preview_at(12.); sample.time55.visual_hour=12.; sample.time55.apply_look()
	sample.label.get_parent().hide(); sample.frames66.panel.hide()
	paused=true
	sample.fade_enabled=false
	advance(sample,70)
	await shot("solid")
	sample.fade_enabled=true
	advance(sample,70,1./240.)
	var key: int=target.visual.get_instance_id()
	var entry: Dictionary=sample.whole67.entries[key]
	verify(entry.target and entry.opacity<.001,"body occlusion fades the entire blocking tree even at high FPS")
	verify("ALPHA=fade*fade" in target.visual.material_override.shader.code and not "window_center66" in target.visual.material_override.shader.code,"whole-tree shader is used and rejected local window is absent")
	var root_material: ShaderMaterial=sample.roots67[key]
	verify(is_equal_approx(root_material.get_shader_parameter("fade"),target.visual.material_override.get_shader_parameter("fade")),"root fade follows the crown without redundant per-frame full-forest writes")
	await shot("buffered")
	var corner: Vector3=target.visual.to_global(Vector3(-target.visual.texture.get_width()*.5+target.visual.offset.x,target.visual.texture.get_height()*.5+target.visual.offset.y,0)*target.visual.pixel_size)
	verify(not sample.whole67.painted_at(target.visual,sample.camera.unproject_position(corner)),"transparent texture corner does not count as a blocking leaf")
	for step in 40:
		sample._teleport15(Vector2(at.x+(step+1)*.35,at.z-2.8))
		advance(sample,1,.07)
		if not entry.target: break
	verify(not entry.target and entry.opacity<.01,"leaving the obstruction retains a short hold instead of flashing back")
	advance(sample,10)
	verify(entry.opacity<.01,"brief boundary excursions do not restore the tree immediately")
	advance(sample,70)
	verify(entry.opacity>.999,"the tree restores after the exit hold")
	sample._teleport15(Vector2(at.x,at.z-2.8))
	sample.whole67.set_improved(false)
	advance(sample,60)
	verify(target.visual.material_override.get_shader_parameter("fade")<.999,"original whole-tree fade is available for comparison")
	await shot("legacy")
	sample.whole67.set_improved(true)
	advance(sample,60)
	var pushes: int=sample.porch49.daylight_pushes67
	for i in 20: sample.porch49.apply_daylight(sample.porch49.daylight55)
	verify(sample.porch49.daylight_pushes67==pushes,"unchanged daylight does not resend all material parameters")
	sample.time55.visual_hour=22.; sample.time55.apply_look()
	var material := ShaderMaterial.new()
	material.shader=preload("res://scripts/art/forest_wind_fade46.gdshader")
	sample.porch49.shade_material(material)
	verify(is_equal_approx(material.get_shader_parameter("porch_light_strength49"),lerpf(.38,1.,sample.porch49.daylight55)),"new night fade material receives the current daylight immediately")
	sample.frames66.panel.show()
	sample.frames66.refresh(Time.get_ticks_usec()/1000000.)
	verify("同步" in sample.frames66.readout.text and "上限不限" in sample.frames66.readout.text,"monitor shows synchronization, resolution and real frame cap")
	var sync := DisplayServer.window_get_vsync_mode()
	var key_event := event(KEY_F11); key_event.ctrl_pressed=true
	sample._unhandled_input(key_event)
	verify(DisplayServer.window_get_vsync_mode()!=sync,"Ctrl+F11 changes synchronization for a live comparison")
	sample._unhandled_input(key_event)
	paused=false
	sample.label.get_parent().show()
	sample.time55.visual_hour=12.; sample.time55.apply_look()
	sample._travel_region("home")
	for i in 30: await physics_frame
	sample.hero.controls_enabled=true
	var results := {}
	for mode in [false,true,true,false]:
		sample.whole67.set_improved(mode)
		sample._teleport15(sample.meadow.main_route[4])
		for i in 20: await physics_frame
		var tag := ("buffered" if mode else "legacy")+str(results.size())
		results[tag]=await record(sample,240,true)
		print("WHOLE67_PERF ",tag," ",JSON.stringify(results[tag]))
	sample.whole67.set_improved(true)
	sample.go_roots64()
	sample.frames66.clear_samples()
	for i in 80: await physics_frame
	await shot("live_monitor")
	var file := FileAccess.open("res://docs/whole67-validation.json",FileAccess.WRITE)
	file.store_string(JSON.stringify({"checks":checks,"failures":failures,"performance_with_guide_visible":results},"\t"))
	print("WHOLE67 ",checks," checks; failures=",failures.size())
	quit(0 if failures.is_empty() else 1)
