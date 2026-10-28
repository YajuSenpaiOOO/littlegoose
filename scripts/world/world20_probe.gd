extends "res://scripts/world/world19_probe.gd"

func run() -> void:
	var sample: Node3D = load("res://scenes/world/world20.tscn").instantiate()
	root.add_child(sample)
	sample.hero.controls_enabled = false
	for i in 16: await physics_frame
	verify(sample.house_variant==0 and is_equal_approx(sample.house_fits[0].height,6.37),"accepted house grows 30 percent, including fitted volume and collision")
	verify(sample.cottage_root.scale==Vector3.ONE,"house physics retains unit scale")
	verify(sample.meadow.named_routes.size()==6,"five connections plus a closed ring are available")
	verify(sample.landmark_tree.height==18.,"central landmark reuses accepted tree art at prototype scale")
	var max_segments := 0
	for chunk in sample.meadow.chunks: max_segments = maxi(max_segments,chunk.segments.size())
	verify(max_segments<=64,"ring road fits local shader segment capacity")
	var grove: Vector2 = sample.meadow.landmarks.grove
	verify(is_equal_approx(sample.meadow.height_at(grove.x,grove.y,true),1.92),"grove center is a level raised arena")
	verify(is_instance_valid(sample.stairs_mesh),"native stone stair blockout is present")
	for route in sample.meadow.named_routes: await walk_route(sample,route)
	for route in sample.meadow.named_routes:
		if route.name=="junction_to_grove" or route.name=="junction_ring":
			var reverse: Dictionary = route.duplicate()
			var points: PackedVector2Array = route.points.duplicate()
			points.reverse()
			reverse.name = route.name+"_reverse"
			reverse.points = points
			await walk_route(sample,reverse)
	for key in ["home","junction","grove","shore","station","landing","steps"]:
		sample._travel_region(key)
		for i in 10: await physics_frame
		verify(sample.hero.is_on_floor(),"region shortcut lands on floor: "+key)
	report.checks = checks
	report.failures = failures
	report.max_local_road_segments = max_segments
	FileAccess.open("res://docs/world20-validation.json",FileAccess.WRITE).store_string(JSON.stringify(report,"\t"))
	print("WORLD20_PROBE ",checks," checks; failures=",failures.size())
	quit(0 if failures.is_empty() else 1)
