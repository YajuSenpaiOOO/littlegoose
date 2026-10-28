extends SceneTree
## Verify proposed lane clearance against real current colliders, not image pixels.
func _initialize() -> void: call_deferred("_run")

func _run() -> void:
	var scene: Node2D = load("res://scenes/sandbox/home_pixel_study.tscn").instantiate()
	root.add_child(scene)
	await physics_frame
	await physics_frame
	scene.hero.frozen = true
	var plan: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://docs/courtyard-route-reservations.json"))
	var shape := CircleShape2D.new()
	shape.radius = float(plan.corridor_width)*0.5
	var query := PhysicsShapeQueryParameters2D.new()
	query.shape = shape
	query.collision_mask = 1
	query.exclude = [scene.hero.get_rid(),scene.enemy.get_rid()]
	var samples := 0
	for i in range(plan.centerline.size()-1):
		var a := Vector2(plan.centerline[i][0],plan.centerline[i][1])
		var b := Vector2(plan.centerline[i+1][0],plan.centerline[i+1][1])
		var steps := ceili(a.distance_to(b)/2.0)
		for j in range(steps+1):
			var at := a.lerp(b,float(j)/steps)
			if not scene.courtyard_ground.on_dirt(at):
				push_error("Courtyard lane center leaves the visible ground at %s" % at)
				quit(1)
				return
			query.transform = Transform2D(0,at)
			var hits := scene.get_world_2d().direct_space_state.intersect_shape(query)
			if not hits.is_empty():
				push_error("Proposed courtyard lane blocked at %s by %s" % [at,hits[0].collider.name])
				quit(1)
				return
			samples += 1
	print("COURTYARD_ROUTE_PROBE PASS: ",samples," clearance samples at 40-unit width; future boundary connections remain planned")
	scene.queue_free()
	await process_frame
	quit(0)
