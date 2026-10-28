extends SceneTree
var failures := 0
var checks := 0

func _initialize() -> void: call_deferred("_run")

func verify(value: bool,message: String) -> void:
	checks += 1
	if value: print("PASS ",message)
	else:
		failures += 1
		push_error(message)

func key(scene: Node,code: Key) -> void:
	var event := InputEventKey.new()
	event.physical_keycode = code
	event.pressed = true
	scene._unhandled_key_input(event)

func _run() -> void:
	var scene: Node2D = load("res://scenes/sandbox/prop_study_35.tscn").instantiate()
	root.add_child(scene)
	await process_frame
	verify(scene.angle_index==1 and scene.bodies.size()==4,"four props load at fixed 35 degree camera")
	var complete := true
	for body in scene.bodies:
		complete = complete and body.node.get_child_count()==1 and body.node.get_child(0) is Sprite2D
	verify(complete,"all four prop instances use separate generated sprite assets")
	key(scene,KEY_1)
	verify(scene.angle_index==1,"art view rejects unsupported angle changes")
	key(scene,KEY_B)
	verify(not scene.art_enabled and scene.bodies[0].node.get_child_count()>1,"whitebox comparison switches to geometric objects")
	key(scene,KEY_B)
	verify(scene.art_enabled and scene.bodies[0].node.get_child(0) is Sprite2D,"switching back restores generated art")
	var prop: Sprite2D = scene.bodies[0].node.get_child(0)
	var before_scale := prop.get_global_transform_with_canvas().get_scale()
	scene.ground_position = Vector2(-280,250)
	key(scene,KEY_C)
	for i in 8: scene._process(0.2)
	scene.camera.force_update_scroll()
	var after_scale := prop.get_global_transform_with_canvas().get_scale()
	verify(scene.camera.position.distance_to(Vector2(800,500))>80,"follow camera translates when the character moves")
	verify(before_scale.is_equal_approx(after_scale),"camera follow keeps world props the same screen scale")
	verify(scene.footprints[3].size.x==180,"stone blocking area matches its wider art footprint")
	print("PROP_STUDY_PROBE ",checks-failures,"/",checks," passed")
	scene.queue_free()
	await process_frame
	quit(0 if failures==0 else 1)
