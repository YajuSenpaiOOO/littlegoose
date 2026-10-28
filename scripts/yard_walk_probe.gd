extends SceneTree
var checks := 0
var failures := 0

func _initialize() -> void: call_deferred("_run")

func verify(condition: bool,message: String) -> void:
	checks += 1
	if condition: print("PASS ",message)
	else:
		failures += 1
		push_error(message)

func key(scene: Node,code: Key) -> void:
	var event := InputEventKey.new()
	event.physical_keycode = code
	event.pressed = true
	scene._unhandled_key_input(event)

func _run() -> void:
	var scene: Node2D = load("res://scenes/sandbox/yard_walk_study.tscn").instantiate()
	root.add_child(scene)
	await process_frame
	verify(scene.follow_enabled and scene.camera.is_current(),"camera follows by default")
	verify(scene.terrain.material.get_shader_parameter("grass_texture") is Texture2D and scene.terrain.material.get_shader_parameter("dirt_texture") is Texture2D,"both generated ground textures loaded")
	verify(is_equal_approx(scene.terrain.size.y/scene.terrain.size.x,sin(deg_to_rad(35.0))),"ground is projected with the same depth compression as the props")
	var half := root.get_visible_rect().size*0.5
	var lower: Vector2 = scene.p(scene.GROUND_BOUNDS.position)
	var upper: Vector2 = scene.p(scene.GROUND_BOUNDS.end)
	for direction in [Vector2(-1,-1),Vector2(1,-1),Vector2(-1,1),Vector2(1,1)]:
		var center: Vector2 = scene._camera_center(direction*100000.0)
		var view := Rect2(center-half,half*2.0)
		verify(view.position.x>=lower.x-0.01 and view.position.y>=lower.y-0.01 and view.end.x<=upper.x+0.01 and view.end.y<=upper.y+0.01,"camera stays within textured terrain at corner %s" % direction)
	key(scene,KEY_T)
	verify(not scene.textured_ground and not scene.terrain.visible,"flat-ground comparison hides the textured plane")
	key(scene,KEY_T)
	verify(scene.textured_ground and scene.terrain.visible,"textured ground can be restored")
	key(scene,KEY_C)
	verify(not scene.follow_enabled,"fixed-camera comparison remains available")
	key(scene,KEY_C)
	var prop: Sprite2D = scene.bodies[0].node.get_child(0)
	var scale_before := prop.get_global_transform_with_canvas().get_scale()
	scene.ground_position = Vector2(570,380)
	for i in 10: scene._process(0.2)
	scene.camera.force_update_scroll()
	verify(prop.get_global_transform_with_canvas().get_scale().is_equal_approx(scale_before),"camera movement does not rescale props")
	print("YARD_WALK_PROBE ",checks-failures,"/",checks," passed")
	scene.queue_free()
	await process_frame
	quit(0 if failures==0 else 1)
