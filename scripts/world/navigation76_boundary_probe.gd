extends "res://scripts/ground_lab_probe.gd"
func run() -> void:
	var stage := Node3D.new();root.add_child(stage);await physics_frame
	var s := preload("res://scripts/world/world_surface76.gd").new()
	var nav := preload("res://scripts/combat/woodland_navigation76.gd").new()
	nav.bake(stage.get_world_3d().direct_space_state,s,s.landmarks.grove)
	var outside_safe := true
	for y in nav.grid.region.size.y:
		for x in nav.grid.region.size.x:
			var at: Vector2=nav.origin+Vector2(x,y)*nav.CELL
			if not s.world_bounds.grow(-.75).has_point(at) or s.is_water(at): outside_safe=outside_safe and nav.grid.is_point_solid(Vector2i(x,y))
	verify(nav.outside_cells76>0 and outside_safe,"larger enemy grid masks every cell beyond playable bounds or in water")
	var g: Vector2=s.landmarks.grove
	var route: PackedVector2Array=nav.path(g+Vector2(-18,0),g+Vector2(18,0))
	verify(not route.is_empty() and route[-1].distance_to(g+Vector2(18,0))<.6,"expanded clearing still has an unclamped cross-field navigation goal")
	var file := FileAccess.open("res://docs/navigation76-boundary-validation.json",FileAccess.WRITE)
	file.store_string(JSON.stringify({"checks":checks,"failures":failures,"masked_cells":nav.outside_cells76},"\t"))
	print("NAVIGATION76_BOUNDARY checks=",checks," failures=",failures.size()," masked=",nav.outside_cells76)
	quit(0 if failures.is_empty() else 1)
