extends SceneTree
var failures: Array[String] = []
var sample_count := 0
func _initialize() -> void:
	_run.call_deferred()
func _run() -> void:
	var scene: Node2D = load("res://scenes/world/world_restart.tscn").instantiate()
	root.add_child(scene)
	var initial_sky: int = scene.sky_index
	await process_frame
	await physics_frame
	await physics_frame
	var circle := CircleShape2D.new()
	circle.radius = 7
	var query := PhysicsShapeQueryParameters2D.new()
	query.shape = circle
	query.collision_mask = 1
	query.exclude = [scene.hero.get_rid()]
	for route_index in scene.routes.size():
		var points: PackedVector2Array = scene.routes[route_index]
		var hits := 0
		for i in points.size()-1:
			var steps := ceili(points[i].distance_to(points[i+1])/4.0)
			for j in steps+1:
				var at := points[i].lerp(points[i+1],float(j)/steps)
				query.transform = Transform2D(0,at)
				var result: Array = scene.get_world_2d().direct_space_state.intersect_shape(query,1)
				sample_count += 1
				if not result.is_empty():
					if hits<3: print("BLOCKED ",scene.plan.routes[route_index].name," ",at," ",result[0].collider.get_parent().name)
					hits += 1
		if hits: failures.append("%s: %d blocked samples" % [scene.plan.routes[route_index].name,hits])
		else: print("PASS route ",scene.plan.routes[route_index].name)
	for at in [Vector2(2000,300),Vector2(1900,1300)]:
		query.transform = Transform2D(0,at*scene.layout_scale)
		if scene.get_world_2d().direct_space_state.intersect_shape(query,1).is_empty(): failures.append("Missing lake collision "+str(at))
	# Sweep the actual body forward and backward along the shared route points.
	for points in scene.routes:
		for reverse in [false,true]:
			var path: PackedVector2Array = points.duplicate()
			if reverse: path.reverse()
			scene.hero.position = path[0]
			for i in path.size()-1:
				var collision: KinematicCollision2D = scene.hero.move_and_collide(path[i+1]-scene.hero.position)
				if collision: failures.append("Actor movement blocked: "+str(path[i]))
			if scene.hero.position.distance_to(path[path.size()-1])>0.1: failures.append("Actor did not reach route endpoint")
	if scene.get_node_or_null("IndependentStandingProps"): failures.append("Old courtyard unexpectedly loaded")
	for code in [KEY_1,KEY_2,KEY_3,KEY_4]:
		var event := InputEventKey.new()
		event.pressed = true
		event.physical_keycode = code
		scene._unhandled_key_input(event)
		if scene.overview or scene.hero.frozen: failures.append("Travel key did not enter walking mode")
		query.transform = Transform2D(0,scene.hero.position)
		if not scene.get_world_2d().direct_space_state.intersect_shape(query,1).is_empty(): failures.append("Travel destination blocked")
	for code in [KEY_TAB,KEY_B,KEY_B,KEY_N,KEY_N]:
		var event := InputEventKey.new()
		event.pressed = true
		event.physical_keycode = code
		scene._unhandled_key_input(event)
	if not scene.overview or not scene.hero.frozen or not scene.world.visible: failures.append("Overview/blockout restore failed")
	if scene.sky_index!=(initial_sky+2)%scene.skies.size(): failures.append("Sky cycling failed")
	# Camera response must be independent of caller frame rate for a fixed target.
	scene.overview = false
	scene.play_zoom = 2.15
	scene.camera.zoom = Vector2.ONE*2.15
	var origin: Vector2 = scene.hero.position+Vector2(-100,-100)
	scene.camera.position = origin
	for i in 30: scene._apply_camera(false,1.0/30)
	var at_30: Vector2 = scene.camera.position
	scene.camera.position = origin
	for i in 144: scene._apply_camera(false,1.0/144)
	if scene.camera.position.distance_to(at_30)>0.01: failures.append("Frame-dependent camera smoothing")
	var before: Vector2 = scene.camera.position
	var key := InputEventKey.new()
	key.pressed = true
	key.physical_keycode = KEY_M
	scene._unhandled_key_input(key)
	if scene.camera.position!=before: failures.append("Unrelated key snapped camera")
	var wheel := InputEventMouseButton.new()
	wheel.pressed = true
	wheel.button_index = MOUSE_BUTTON_WHEEL_UP
	wheel.factor = 1
	scene._unhandled_input(wheel)
	if scene.play_zoom<=2.15: failures.append("Wheel did not zoom in")
	for i in 80: scene._unhandled_input(wheel)
	if scene.play_zoom!=scene.ZOOM_MAX: failures.append("Zoom upper bound failed")
	wheel.button_index = MOUSE_BUTTON_WHEEL_DOWN
	for i in 100: scene._unhandled_input(wheel)
	if scene.play_zoom!=scene.ZOOM_MIN: failures.append("Zoom lower bound failed")
	scene._apply_camera(true)
	if not scene.camera.position.is_finite(): failures.append("Zoomed-out camera invalid at world bounds")
	scene.play_zoom = 1.35
	key.physical_keycode = KEY_TAB
	scene._unhandled_key_input(key)
	scene._unhandled_key_input(key)
	if scene.play_zoom!=1.35 or not is_equal_approx(scene.camera.zoom.x,1.35): failures.append("Tab lost user zoom")
	if not physics_interpolation: failures.append("Motion interpolation disabled")
	print("WORLD_RESTART_PROBE samples=",sample_count," failures=",failures)
	quit(0 if failures.is_empty() else 1)
