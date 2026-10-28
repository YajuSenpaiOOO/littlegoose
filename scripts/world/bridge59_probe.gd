extends "res://scripts/world/woodland46_probe.gd"
class BridgeSample:
	extends "res://scripts/world/world59.gd"
	func _hero_script() -> Script: return LivingActor
	func fire_input_held() -> bool: return false

func shot59(name: String) -> Image:
	var image: Image=await snapshot()
	image.save_png("res://docs/captures/world_restart/bridge59_"+name+".png")
	return image

func run() -> void:
	var sample: Node3D=BridgeSample.new()
	root.add_child(sample)
	while not is_instance_valid(sample.bridge59) or not sample.bridge59.is_node_ready(): await physics_frame
	for i in 30: await physics_frame
	sample.label.get_parent().hide()
	sample.hero.controls_enabled=false
	var study: Node3D=sample.bridge59
	var rect: Rect2=sample.meadow.bridge_rect
	var collision: Shape3D=sample.bridge_collision.shape
	verify(RenderingServer.get_current_rendering_method()=="gl_compatibility","Compatibility retained")
	verify(study.variants.size()==3 and sample.old_bridge59.size()==23,"three bridge visuals replace the old deck and rails")
	var old_hidden := true
	for piece in sample.old_bridge59: old_hidden=old_hidden and not piece.visible
	verify(old_hidden,"old abstract geometry no longer renders")
	verify(sample.meadow.get_script().resource_path=="res://scripts/world/world_surface21.gd","original geography and bridge span retained")
	verify(sample.time55.accents57.stage_light.spot_angle==30. and not sample.porch49.fill_enabled,"wider spotlight stays separate from body light")
	var focus: ShaderMaterial=sample.atmosphere41.focus_material
	verify(focus.get_shader_parameter("cone_density58")==.13 and focus.get_shader_parameter("cone_spread58")>.57,"wide air light is warmer and more dilute")
	sample.time55.preview_at(12.)
	sample.time55.visual_hour=12.
	sample.time55.apply_look()
	for i in 20: await physics_frame
	paused=true
	var framing: Transform3D=sample.camera.transform
	var images: Array[Image]=[]
	for i in 3:
		study.set_pair(i)
		images.append(await shot59("pair_"+str(i)+"_noon"))
		var visible := 0
		for variant in study.variants: if variant.visible: visible+=1
		verify(visible==1 and study.bridge_style==i and study.water_style==i,"pair %d selects one bridge and matching water"%i)
		verify(sample.bridge_collision.shape==collision and sample.camera.transform==framing,"pair %d preserves collision and camera"%i)
	var area := Rect2i(Vector2i.ZERO,images[0].get_size())
	verify(changed(images[0],images[1],area)>30000 and changed(images[1],images[2],area)>30000,"three options visibly differ in actual game frames")
	study.set_pair(0)
	study.set_water(2)
	verify(study.bridge_style==0 and study.water_style==2,"water can be selected independently")
	await shot59("mixed_A_bridge_C_water")
	for i in 3:
		study.set_pair(i)
		sample.time55.preview_at(22.)
		sample.time55.visual_hour=22.
		sample.time55.apply_look()
		study._process(0.)
		await shot59("pair_"+str(i)+"_night")
	verify(sample.time55.accents57.stage_light.light_energy==4. and sample.time55.accents57.stage_light.spot_range==11.,"wider night spot uses reduced energy and no extra light")
	verify(sample.time55.accents57.flies.size()==32,"firefly budget unchanged")
	paused=false
	sample.time55.preview_at(12.)
	sample.time55.visual_hour=12.
	sample.time55.apply_look()
	var crossed := []
	for i in 3:
		study.set_pair(i)
		var from := Vector2(rect.position.x-.6,rect.get_center().y)
		var to := Vector2(rect.end.x+.6,rect.get_center().y)
		sample._teleport15(from)
		sample.hero.controls_enabled=true
		for step in 8: await physics_frame
		var reached_middle: bool=await walk_to(sample,rect.get_center())
		var ok: bool=reached_middle and await walk_to(sample,to)
		crossed.append(ok)
		verify(ok,"variant %d can be walked across both banks"%i)
		sample.hero.controls_enabled=false
	verify(sample.bridge_collision.shape==collision,"walking and selection never rebuild bridge collision")
	study.set_pair(0)
	sample.go_bridge59()
	for i in 20: await physics_frame
	paused=true
	sample.label.get_parent().show()
	sample.time55.update_guide()
	await shot59("guide")
	var file := FileAccess.open("res://docs/bridge59-validation.json",FileAccess.WRITE)
	file.store_string(JSON.stringify({"checks":checks,"failures":failures,"walked":crossed,"draw_pieces":study.draw_pieces,"hidden_intruding_trees":study.submerged_trees.size()},"\t"))
	print("BRIDGE59 ",checks," checks; failures=",failures.size())
	quit(0 if failures.is_empty() else 1)
