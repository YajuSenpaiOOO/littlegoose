extends "res://scripts/world/landscape78_probe.gd"
func run() -> void:
	var sample := LandscapeSample.new();root.add_child(sample)
	while not is_instance_valid(sample.scenery78): await physics_frame
	await settle72()
	var s: RefCounted=sample.meadow
	verify(sample.water_material19.get_shader_parameter("shore59")!=null,"curved shoreline depth mask is imported and bound")
	verify(sample.bridge59.shore_material.shader.code.contains("VIEW_MATRIX*vec4(0.,1.,0.,0.)"),"two-sided shoreline uses an upward normal on both polygon windings")
	sample.label.get_parent().hide();sample.frames66.panel.hide()
	await shot78(sample,Vector2(-48,-59),"rear_rocks")
	await shot78(sample,s.landmarks.grove+Vector2(0,4),"field")
	await shot78(sample,s.landmarks.shore+Vector2(2,-7),"shore")
	await shot78(sample,Vector2(s.bridge_rect.position.x-2.,s.bridge_rect.get_center().y+1.),"bridge")
	sample.time55.preview_at(22.);sample.time55.visual_hour=22.;sample.time55.apply_look()
	await shot78(sample,Vector2(-48,-59),"rear_night")
	sample.time55.preview_at(12.);sample.time55.visual_hour=12.;sample.time55.apply_look()
	sample.set_review72(true);await settle72()
	var overview := await snapshot();overview.save_png("res://docs/captures/world_restart/landscape78_overview.png")
	sample.set_review72(false);sample.hero.controls_enabled=true
	verify(await walk_route72(sample,"junction_to_grove"),"forest approach still traverses after alternating cliff and shoulder refinement")
	var file := FileAccess.open("res://docs/landscape78-visual-validation.json",FileAccess.WRITE);file.store_string(JSON.stringify({"checks":checks,"failures":failures},"\t"))
	print("LANDSCAPE78_VISUAL ",checks," failures=",failures.size());quit(0 if failures.is_empty() else 1)
