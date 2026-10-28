extends "res://scripts/ground_lab_probe.gd"
var report: Dictionary = {"routes":[]}

func drive(keys: Array) -> void:
	for key in [KEY_W,KEY_A,KEY_S,KEY_D]:
		var input := event(key)
		input.pressed = key in keys
		Input.parse_input_event(input)

func walk_route(sample: Node3D,route: Dictionary) -> void:
	var points: PackedVector2Array = route.points
	sample._teleport15(points[0])
	for i in 8: await physics_frame
	sample.hero.controls_enabled = true
	var target := 1
	var grounded := true
	var steps := 0
	var last := Vector2(sample.hero.position.x,sample.hero.position.z)
	var stuck := 0
	var distance := 0.
	for step in 1900:
		steps += 1
		var at := Vector2(sample.hero.position.x,sample.hero.position.z)
		while target<points.size() and at.distance_to(points[target])<.43: target += 1
		if target>=points.size(): break
		var direction: Vector2 = (points[target]-at).normalized()
		var keys: Array = []
		if direction.x>.32: keys.append(KEY_D)
		if direction.x<-.32: keys.append(KEY_A)
		if direction.y>.32: keys.append(KEY_S)
		if direction.y<-.32: keys.append(KEY_W)
		drive(keys)
		await physics_frame
		var now := Vector2(sample.hero.position.x,sample.hero.position.z)
		distance += now.distance_to(last)
		stuck = stuck+1 if now.distance_to(last)<.004 else 0
		last = now
		grounded = grounded and sample.hero.position.y> -1.0
		if stuck>75: break
	drive([])
	sample.hero.controls_enabled = false
	for i in 5: await physics_frame
	var finished := target>=points.size()
	verify(finished and grounded,"actual input traverses %s without water fall or hidden sample boundary"%route.name)
	var item := {"name":route.name,"completed":finished,"physics_seconds":steps/60.,"travelled_metres":distance,"at":[sample.hero.position.x,sample.hero.position.z],"target":target,"points":points.size()}
	report.routes.append(item)
	print("ROUTE19 ",JSON.stringify(item))

func run() -> void:
	var started := Time.get_ticks_msec()
	var sample: Node3D = load("res://scenes/world/world19.tscn").instantiate()
	root.add_child(sample)
	report.build_seconds = (Time.get_ticks_msec()-started)/1000.
	print("BUILD19_SECONDS ",report.build_seconds)
	sample.hero.controls_enabled = false
	for i in 16: await physics_frame
	verify(sample.world_ready and sample.house_variant==0 and sample.art_style==1,"whole map loads accepted house1 and environment style2")
	verify(sample.meadow.named_routes.size()==5 and sample.meadow.landmarks.size()==6,"all five old route connections and six destination anchors are mapped")
	verify(sample.meadow.world_bounds.size.x>120. and sample.meadow.main_route[-1].y< -30.,"geography preserves expanded spacing without scaling character or house")
	var max_segments := 0
	for chunk in sample.meadow.chunks: max_segments = maxi(max_segments,chunk.segments.size())
	verify(max_segments<=64 and max_segments<sample.meadow.segments.size(),"ground chunks use local road lists within shader capacity")
	verify(sample.ground.material_override==null and sample.ground_materials.size()==sample.ground.mesh.get_surface_count(),"every terrain surface has its own local-road material")
	verify(sample.grass_batches.size()>30 and sample.grass_batches[0].node.visibility_range_end<=46.,"reactive grass is spatially batched with a finite display range")
	var trunks_clear := true
	for tree in sample.trees:
		var at: Vector3 = tree.root.position
		trunks_clear = trunks_clear and sample.meadow.route_distance(Vector2(at.x,at.z))>=1.84
	verify(trunks_clear,"tree placement keeps all route centers clear without old single-route shifts")
	verify(sample.root_pieces.size()==sample.trees.size() and sample.fitted_cards.size()==sample.props15.size(),"all world trees and furniture retain accepted root and shadow treatment")
	for route in sample.meadow.named_routes: await walk_route(sample,route)
	verify(sample.tracks.active_count()>0,"existing footprint emitter remains active on the whole-map roads")
	var tracks_synced := true
	for material in sample.ground_materials:
		var marks: PackedVector4Array = material.get_shader_parameter("footprints")
		tracks_synced = tracks_synced and marks==sample.tracks.marks
	verify(tracks_synced,"world-coordinate footprints are synchronized across all terrain chunks")
	# Water must remain blocked alongside the traversable bridge.
	var bridge: Rect2 = sample.meadow.bridge_rect
	var water_point := bridge.get_center()+Vector2(0,bridge.size.y)
	var query := PhysicsRayQueryParameters3D.create(Vector3(water_point.x,4,water_point.y),Vector3(water_point.x,-2,water_point.y),2)
	var hit := sample.get_world_3d().direct_space_state.intersect_ray(query)
	verify(not hit.is_empty() and hit.collider.name.begins_with("WaterBoundary"),"water beside bridge is blocked by a real collision volume")
	var deck_query := PhysicsRayQueryParameters3D.create(Vector3(bridge.get_center().x,4,bridge.get_center().y),Vector3(bridge.get_center().x,-2,bridge.get_center().y),1)
	var deck := sample.get_world_3d().direct_space_state.intersect_ray(deck_query)
	verify(not deck.is_empty() and deck.position.y>0.,"bridge deck participates in the same real floor collision as terrain")
	for key in ["home","junction","grove","shore","station","landing"]:
		sample._travel_region(key)
		for i in 10: await physics_frame
		verify(sample.hero.is_on_floor(),"region shortcut lands on playable ground: "+key)
	sample._unhandled_input(event(KEY_TAB))
	verify(sample.map_panel.visible,"Tab reveals the shared-coordinate route map")
	verify(sample.meadow.profile.enabled and sample.soil_spots,"shallow shoulders and soil variation remain enabled in the world")
	sample._travel_region("junction")
	for i in 80: await physics_frame
	report.fps = Engine.get_frames_per_second()
	report.draw_calls = Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME)
	report.trees = sample.trees.size()
	report.grass_chunks = sample.grass_batches.size()
	report.terrain_chunks = sample.meadow.chunks.size()
	report.max_local_road_segments = max_segments
	report.checks = checks
	report.failures = failures
	var file := FileAccess.open("res://docs/world19-validation.json",FileAccess.WRITE)
	file.store_string(JSON.stringify(report,"\t"))
	print("WORLD19_PROBE ",checks," checks; failures=",failures.size()," FPS=",report.fps)
	quit(0 if failures.is_empty() else 1)
