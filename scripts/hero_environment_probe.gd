extends SceneTree
var checks := 0
var failures: Array[String] = []
func _initialize() -> void:
	_run.call_deferred()
func verify(condition: bool,message: String) -> void:
	checks += 1
	if not condition: failures.append(message)
	print("PASS " if condition else "FAIL ",message)
func _run() -> void:
	var scene: Node2D = load("res://scenes/world/world_restart.tscn").instantiate()
	root.add_child(scene)
	await process_frame
	await physics_frame
	await physics_frame
	verify(scene.style_trees.size()==6,"six authored tree trials loaded independently")
	verify(scene.sky_index==1 and scene.rig.profile.resource_path.ends_with("hero_environment_v1/day.tres"),"neutral warm daylight is the default review light")
	var tree: Node2D = scene.world.get_node("OakCalibration")
	var body: StaticBody2D = tree.get_node("Footprint")
	var hit: CollisionShape2D = body.get_child(0)
	verify(hit.shape is ConvexPolygonShape2D,"rounded trunk footprint uses real convex physics")
	var image: Image = tree.profile.texture.get_image()
	verify(image.get_pixelv(Vector2i(tree.profile.anchor_px)).a>0.9,"declared foot point lies on solid visible root")
	verify(tree.visual.position.is_equal_approx(-tree.profile.anchor_px*tree.visual.scale),"image foot maps to sorting origin")
	verify(tree.position.is_equal_approx(Vector2(1270,1255)*scene.layout_scale),"geographic spacing does not inflate tree art or collision")
	verify(hit.shape.get_rect().size.is_equal_approx(Vector2(62,22)),"actual trunk size stays 62 by 22 after world expansion")
	var center := body.global_position
	var hero: CharacterBody2D = scene.hero
	hero.set_physics_process(false)
	for direction in [Vector2.LEFT,Vector2.RIGHT,Vector2.UP,Vector2.DOWN]:
		hero.position = center+direction*85+Vector2(0,2)
		hero.reset_physics_interpolation()
		var collision := hero.move_and_collide(-direction*85)
		verify(collision!=null and collision.get_collider()==body,"root blocks real player from "+str(direction))
	# Travel across the upper crown away from the trunk: art never becomes a wall.
	hero.position = tree.position+Vector2(-85,-88)
	hero.reset_physics_interpolation()
	verify(hero.move_and_collide(Vector2(170,0))==null,"can walk under canopy outside trunk footprint")
	var sibling: Node2D = scene.world.get_node("OakWest")
	tree.collision_adjust = Vector2(3,-2)
	tree.footprint_override = Vector2(54,18)
	verify(body.position.is_equal_approx(Vector2(3,-6)),"live instance offset immediately reaches actual body")
	verify(hit.shape.get_rect().size.is_equal_approx(Vector2(54,18)),"live instance size immediately reaches actual shape")
	verify(sibling.collision_adjust==Vector2.ZERO and sibling.footprint_override==Vector2(-1,-1),"instance tuning leaves sibling and source resource intact")
	tree.collision_adjust = Vector2.ZERO
	tree.footprint_override = Vector2(-1,-1)
	var key := InputEventKey.new()
	key.pressed = true
	key.physical_keycode = KEY_H
	scene._unhandled_key_input(key)
	verify(tree.collision_overlay!=null and tree.collision_overlay.visible and tree.collision_overlay.z_index>0,"H draws the actual shape over root artwork")
	scene._unhandled_key_input(key)
	verify(not tree.collision_overlay.visible,"H hides collision overlay")
	key.physical_keycode = KEY_P
	var camera_position: Vector2 = scene.camera.position
	var original_style: bool = scene.warm_style
	var original_light: Resource = scene.rig.profile
	scene._unhandled_key_input(key)
	verify(scene.warm_style!=original_style and scene.rig.profile==original_light,"P compares ground under identical light")
	scene._unhandled_key_input(key)
	verify(scene.warm_style==original_style and scene.camera.position==camera_position,"P restores material without moving camera")
	print("HERO_ENVIRONMENT_PROBE ",checks-failures.size(),"/",checks," failures=",failures)
	quit(0 if failures.is_empty() else 1)
