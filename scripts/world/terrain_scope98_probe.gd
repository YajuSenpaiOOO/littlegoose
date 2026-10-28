extends SceneTree
func _initialize() -> void: call_deferred("run")
func run() -> void:
	var previous=preload("res://scripts/world/world_surface96.gd").new()
	var old_park=preload("res://scripts/world/world_surface97.gd").new()
	var current=preload("res://scripts/world/world_surface98.gd").new()
	var g: Vector2=current.landmarks.grove
	var count := 0;var different := 0;var worst := 0.;var examples: Array=[]
	var historical := {}
	for at in [Vector2(0,0),Vector2(7,-42.7),Vector2(10,-45.9),Vector2(4.8,-45.9),Vector2(50,-20),Vector2(20,0)]:
		historical[str(at)]=[previous.height_at(at.x,at.y,true),old_park.height_at(at.x,at.y,true),current.height_at(at.x,at.y,true)]
	# Keep the approved park approach when comparing terrain: roads influence
	# the inherited shoulders even just outside the woodland construction area.
	previous.named_routes=current.named_routes.duplicate(true);previous._reindex_routes()
	var bounds: Rect2=current.world_bounds
	for z in range(ceili(bounds.position.y),floori(bounds.end.y),3):
		for x in range(ceili(bounds.position.x),floori(bounds.end.x),3):
			var p := Vector2(x,z)-g
			# Contains the authored woodland and its re-routed approach only.
			if p.x<31. and p.y> -39. and p.y<28.: continue
			count+=1
			var before: float=previous.height_at(x,z,true);var after: float=current.height_at(x,z,true)
			var delta := absf(before-after);worst=maxf(worst,delta)
			if delta>.0001:
				different+=1
				if examples.size()<8: examples.append([x,z,before,after])
	var data := {"samples":count,"road_layout_aligned":true,"changed_outside_woodland":different,"max_difference":worst,"examples":examples,"heights_96_97_current":historical}
	var file := FileAccess.open("res://docs/terrain-scope98-validation.json",FileAccess.WRITE);file.store_string(JSON.stringify(data,"\t"))
	print("TERRAIN_SCOPE98 ",JSON.stringify(data));quit(0 if different==0 else 1)
