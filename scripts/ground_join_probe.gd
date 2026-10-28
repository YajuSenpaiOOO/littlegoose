extends SceneTree
var checks := 0
var failures := 0
func _initialize() -> void: call_deferred("_run")
func verify(value: bool,message: String) -> void:
	checks += 1
	if value: print("PASS ",message)
	else:
		failures += 1
		push_error(message)
func _run() -> void:
	var props: Node2D = load("res://scenes/world/courtyard_props.tscn").instantiate()
	var pine: Node2D = props.get_node("Tree00")
	var sibling: Node2D = props.get_node("Tree03")
	pine.collision_adjust = Vector2(-3,1)
	pine.footprint_override = Vector2(30,18)
	root.add_child(props)
	verify(props.get_child_count()==36,"all thirty-six principal props including garden additions are editable scene nodes")
	verify(pine.get_node("Footprint").position.is_equal_approx((pine.profile.footprint_offset+Vector2(-3,1))*pine.size_factor),"per-instance collision offset reaches the real physics body")
	verify(pine.get_node("Footprint").get_child(0).shape.size.is_equal_approx(Vector2(30,18)*pine.size_factor),"per-instance footprint size reaches the real physics shape")
	verify(sibling.collision_adjust==Vector2.ZERO and sibling.footprint_override==Vector2(-1,-1),"one instance can be tuned without modifying its shared sibling")
	props.queue_free()
	await process_frame
	var scene: Node2D = load("res://scenes/sandbox/home_pixel_study.tscn").instantiate()
	root.add_child(scene)
	await process_frame
	await process_frame
	verify(scene.transition_stamps.size()>60,"paving and roots receive reusable flat ground transitions")
	var clear_center := true
	for stamp in scene.transition_stamps:
		clear_center = clear_center and not (stamp.position.distance_to(scene.hero.position)<15)
	verify(clear_center,"new ground details leave the player entrance center open")
	var event := InputEventKey.new()
	event.physical_keycode = KEY_J
	event.pressed = true
	scene._unhandled_key_input(event)
	verify(not scene.transition_stamps[0].visible,"ground transitions can be compared with one key")
	print("GROUND_JOIN_PROBE ",checks-failures,"/",checks," passed")
	scene.queue_free()
	await process_frame
	quit(0 if failures==0 else 1)
