extends "res://scripts/world/lake79_probe.gd"
func run() -> void:
	var sample := LakeSample.new();root.add_child(sample)
	while not is_instance_valid(sample.accents79): await physics_frame
	await settle72()
	var count := 0;var shown := true
	for child in sample.get_children():
		if child is MeshInstance3D and child.material_override==sample.water_material19:
			count+=1;shown=shown and child.visible and absf(child.position.y+.4)<.01
	verify(count==sample.meadow.lake_pieces79().size() and shown,"all split water surfaces remain visible at the approved lowered water level")
	verify(sample.old_bridge59.all(func(node):return node.material_override!=sample.water_material19),"no water piece is misclassified as an old bridge mesh")
	sample.label.get_parent().hide();sample.frames66.panel.hide()
	var s: RefCounted=sample.meadow
	await shot79(sample,s.landmarks.shore+Vector2(2,-7),"island_north")
	await shot79(sample,s.landmarks.shore+Vector2(10,0),"island_east")
	await shot79(sample,s.landmarks.home+Vector2(0,3.3),"home")
	await shot79(sample,s.landmarks.station+Vector2(0,13),"front_steps")
	await shot79(sample,s.SIDE_FOOT75+Vector2(1.1,2.),"side_steps")
	sample.time55.preview_at(22.);sample.time55.visual_hour=22.;sample.time55.apply_look()
	await shot79(sample,s.landmarks.shore+Vector2(2,-7),"island_night")
	sample.time55.preview_at(12.);sample.time55.visual_hour=12.;sample.time55.apply_look()
	sample.set_review72(true);await settle72()
	var overview := await snapshot();overview.save_png("res://docs/captures/world_restart/lake79_overview.png")
	var file := FileAccess.open("res://docs/lake79-visual-validation.json",FileAccess.WRITE);file.store_string(JSON.stringify({"checks":checks,"failures":failures,"water_surfaces":count},"\t"))
	print("LAKE79_VISUAL ",checks," failures=",failures.size());quit(0 if failures.is_empty() else 1)
