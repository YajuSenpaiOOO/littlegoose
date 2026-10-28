extends "res://scripts/world/air52_performance_probe.gd"
class Optimized:
	extends "res://scripts/world/world65.gd"
	var contact_us := 0
	var contact_calls := 0
	var blending_us := 0
	func _hero_script() -> Script: return LivingActor
	func fire_input_held() -> bool: return false
	func _update_prop_contacts() -> void:
		var stamp := contact_stamp65
		var start := Time.get_ticks_usec()
		super._update_prop_contacts()
		contact_us+=Time.get_ticks_usec()-start
		if contact_stamp65!=stamp: contact_calls+=1
	func _update_tree_blending() -> void:
		var start := Time.get_ticks_usec()
		super._update_tree_blending()
		blending_us+=Time.get_ticks_usec()-start

func run() -> void:
	var sample := Optimized.new()
	root.add_child(sample)
	while not is_instance_valid(sample.landmark62) or not sample.landmark62.is_node_ready(): await physics_frame
	for i in 30: await physics_frame
	sample.label.get_parent().hide()
	var study: Node3D=sample.landmark62
	verify(sample.bridge59.moving and sample.bridge59.sparkling and not sample.bridge59.distant_glow,"water motion and sparkles restored")
	verify(study.root_shapes65>2 and study.root_shapes65<40,"root footprint consists of bounded reusable convex pieces")
	var blocked := 0
	var capsule_blocked := 0
	var widest := 0.
	var hero_mask: int=sample.hero.collision_mask
	# Isolate obstacle contacts from sloping ground during horizontal capsule sweeps.
	sample.hero.collision_mask=2
	for collider in study.root_body65.get_children():
		var points: PackedVector3Array=collider.shape.points
		var middle := Vector3.ZERO
		var front := -INF
		for p in points:
			middle+=p/points.size()
			front=maxf(front,p.z)
			widest=maxf(widest,absf(p.x))
		var start: Vector3=study.tree.root.to_global(Vector3(middle.x,.42,front+1.5))
		start.y=sample.floor_height(Vector2(start.x,start.z))+.45
		var end := Vector3(start.x,start.y,study.tree.root.global_position.z+middle.z)
		var hit: Dictionary=sample.get_world_3d().direct_space_state.intersect_ray(PhysicsRayQueryParameters3D.create(start,end,2))
		if not hit.is_empty() and study.tree.root.is_ancestor_of(hit.collider): blocked+=1
		var pose: Transform3D=sample.hero.global_transform
		pose.origin=start-Vector3.UP*.37
		var contact := KinematicCollision3D.new()
		if sample.hero.test_move(pose,end-start,contact) and study.tree.root.is_ancestor_of(contact.get_collider()): capsule_blocked+=1
	verify(blocked==study.root_shapes65,"each spreading root blocks a horizontal approach")
	verify(capsule_blocked==study.root_shapes65,"actual hero capsule cannot cross any root strip")
	sample.hero.collision_mask=hero_mask
	var edge: Vector3=study.tree.root.global_position+Vector3(widest+1.,.45,0)
	var edge_query := PhysicsRayQueryParameters3D.create(edge+Vector3(0,0,6),edge-Vector3(0,0,1),2)
	verify(sample.get_world_3d().direct_space_state.intersect_ray(edge_query).is_empty(),"outside root edge remains open for walking")
	var original_body: StaticBody3D=study.root_body65
	study.set_tree(2)
	verify(study.root_body65!=original_body and study.root_shapes65>2,"changing painted tree regenerates its own footprint")
	study.set_old_tree(true)
	verify(study.root_body65.collision_layer==0,"original small tree does not retain giant root blockers")
	study.set_tree(1)
	verify(study.root_body65.collision_layer==2,"returning to willow restores root blockers")
	sample._travel_region("home")
	for i in 45: await physics_frame
	sample.contact_us=0; sample.contact_calls=0; sample.blending_us=0
	sample.hero.controls_enabled=true
	var result := await record(sample,360,true)
	result.contact_total_ms=sample.contact_us/1000.
	result.contact_calls=sample.contact_calls
	result.tree_blending_total_ms=sample.blending_us/1000.
	result.root_pieces=study.root_shapes65
	var file := FileAccess.open("res://docs/motion65-optimized.json",FileAccess.WRITE)
	file.store_string(JSON.stringify(result,"\t"))
	print("MOTION65_OPTIMIZED ",JSON.stringify(result))
	sample.go_roots64()
	sample.hero.controls_enabled=true
	var hub: Vector2=sample.meadow.landmarks.junction
	verify(await walk_to(sample,hub+Vector2(-3.5,5.7)),"bench-side approach remains walkable")
	for i in 30: await physics_frame
	var shot: Image=await snapshot()
	shot.save_png("res://docs/captures/world_restart/roots_water65.png")
	var validation := FileAccess.open("res://docs/roots-water65-validation.json",FileAccess.WRITE)
	validation.store_string(JSON.stringify({"checks":checks,"failures":failures},"\t"))
	print("ROOTS_WATER65 ",checks," checks; failures=",failures.size())
	quit(0 if failures.is_empty() else 1)
