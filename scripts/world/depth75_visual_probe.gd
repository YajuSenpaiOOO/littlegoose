extends "res://scripts/world/depth75_probe.gd"

func run() -> void:
	var sample := WideSample.new();root.add_child(sample)
	while not is_instance_valid(sample.rail72): await physics_frame
	await settle72()
	sample.label.get_parent().hide();sample.frames66.panel.hide()
	await shot73(sample,sample.meadow.SIDE_FOOT75+Vector2(1.,2.),"side_stairs")
	await shot73(sample,sample.meadow.landmarks.station+Vector2(1.,15.),"station_front")
	sample.set_review72(true);await settle72()
	var overview := await snapshot();overview.save_png("res://docs/captures/world_restart/depth75_overview.png")
	var arrays: Array=sample.rail72.side_stairs75.mesh.surface_get_arrays(0)
	var indices: PackedInt32Array=arrays[Mesh.ARRAY_INDEX]
	var vertices: PackedVector3Array=arrays[Mesh.ARRAY_VERTEX]
	var referenced_wall := false
	for index in indices:
		if vertices[index].z< -47.1: referenced_wall=true;break
	verify(referenced_wall,"retaining-wall triangles remain referenced beside indexed stair boxes")
	print("DEPTH75_VISUAL_READY failures=",failures.size())
	quit(0 if failures.is_empty() else 1)
