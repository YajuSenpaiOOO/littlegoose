extends SceneTree
var checks := 0
var failures: Array[String] = []
func _initialize() -> void: run.call_deferred()
func verify(ok: bool,message: String) -> void:
	checks += 1
	if not ok: failures.append(message)
	print("PASS " if ok else "FAIL ",message)
func key_event(key: Key,pressed: bool) -> void:
	var event := InputEventKey.new()
	event.physical_keycode = key
	event.pressed = pressed
	Input.parse_input_event(event)
func post_height(scene: Node3D,index: int) -> float:
	var at: Vector3 = scene.reference_posts[index].position
	return scene.camera.unproject_position(at+Vector3.UP*.5).distance_to(scene.camera.unproject_position(at-Vector3.UP*.5))
func run() -> void:
	var scene: Node3D = load("res://scenes/sandbox/perspective_playground.tscn").instantiate()
	root.add_child(scene)
	scene.hero.controls_enabled = false
	for i in 12: await physics_frame
	verify(scene.hero is CharacterBody3D and scene.camera is Camera3D and scene.camera.projection==Camera3D.PROJECTION_PERSPECTIVE,"real 3D character and perspective camera")
	verify(is_equal_approx(scene.camera.rotation_degrees.x,-25.),"camera optical axis remains at 25 degrees")
	verify(scene.hero.is_on_floor() and absf(scene.hero.position.y)<.08,"character lands on actual ground collider")
	verify(post_height(scene,0)>post_height(scene,2)*1.5,"equal-size near/far posts have perspective scale difference")
	var toggle := InputEventKey.new()
	toggle.pressed = true
	toggle.physical_keycode = KEY_P
	scene._unhandled_input(toggle)
	scene._update_camera(0,true)
	verify(absf(post_height(scene,0)-post_height(scene,2))<.01,"P switches to orthographic with equal-size post projections")
	scene._unhandled_input(toggle)
	scene._update_camera(0,true)
	# Actual screen ray must acquire the 3D target, not a guessed ground coordinate.
	var point: Vector2 = scene.camera.unproject_position(scene.target.position+Vector3.UP*.65)
	var hit: Dictionary = scene.pick_screen(point)
	verify(not hit.is_empty() and hit.collider==scene.target,"mouse camera ray selects the visible target body")
	var before: int = scene.hits
	scene.fire_at(scene.target.position+Vector3.UP*.65)
	for i in 40: await physics_frame
	verify(scene.hits==before+1,"real 3D swept projectile hits the target")
	# Long segment through the building must still be blocked in one step.
	scene.teleport(Vector3(-2,0,-4))
	for i in 3: await physics_frame
	var blocks: int = scene.blocks
	scene.fire_at(Vector3(-2,.85,-15))
	scene._step_shots(1.)
	verify(scene.blocks==blocks+1,"large projectile step is intercepted by house collision")
	# Climb and descend the real mesh with standard CharacterBody3D motion.
	scene.teleport(Vector3(10,0,1))
	for i in 12: await physics_frame
	scene.hero.controls_enabled = true
	key_event(KEY_W,true)
	for i in 170: await physics_frame
	key_event(KEY_W,false)
	for i in 20: await physics_frame
	verify(scene.hero.position.z < -8 and scene.hero.position.y>1.5 and scene.hero.is_on_floor(),"walking climbs the 1.6-unit slope and stays grounded")
	verify(scene.camera.position.distance_to(scene.hero.position+Vector3(0,.85,0)+Vector3(0,sin(deg_to_rad(25.)),cos(deg_to_rad(25.)))*scene.camera_distance)<.25,"camera follows height changes on the slope")
	key_event(KEY_S,true)
	for i in 170: await physics_frame
	key_event(KEY_S,false)
	for i in 8: await physics_frame
	verify(scene.hero.position.y<.15 and scene.hero.is_on_floor(),"walking descends the slope without floating")
	scene.hero.controls_enabled = false
	# The visual height is real; plants share one instanced material and no bodies.
	verify(scene.grass.multimesh.instance_count==4200 and scene.grass.get_child_count()==0,"4200 grass instances have no per-plant scripts or colliders")
	var clear_planting := true
	for i in scene.grass.multimesh.instance_count:
		var at: Vector3 = scene.grass.multimesh.get_instance_transform(i).origin
		clear_planting = clear_planting and scene._grass_allowed(Vector2(at.x,at.z)) and absf(at.y-scene.terrain_height(at.x,at.z)-.025)<.001
	verify(clear_planting,"meadow roots follow actual terrain and leave roads and solid footprints clear")
	var light: float = scene.sun.light_energy
	toggle.physical_keycode = KEY_V
	scene._unhandled_input(toggle)
	verify(not scene.quiet_ground and not scene.grass.visible and scene.patch_grass.visible and scene.sun.light_energy==light,"V compares old ground and patch grass under unchanged light")
	scene._unhandled_input(toggle)
	verify(scene.quiet_ground and scene.grass.visible and not scene.patch_grass.visible,"V restores the full meadow")
	verify(scene.house_art.visible and scene.house_meshes[0].cast_shadow==GeometryInstance3D.SHADOW_CASTING_SETTING_SHADOWS_ONLY,"generated cottage replaces visible model while retaining its shadow and collision")
	toggle.physical_keycode = KEY_B
	scene._unhandled_input(toggle)
	verify(not scene.house_art.visible and scene.house_meshes[0].cast_shadow==GeometryInstance3D.SHADOW_CASTING_SETTING_ON,"B restores the model for art comparison")
	scene._unhandled_input(toggle)
	toggle.physical_keycode = KEY_J
	scene._unhandled_input(toggle)
	verify(not scene.painted_grass and not scene.grass_material.get_shader_parameter("painted_grass"),"J switches grass source without changing placement")
	scene._unhandled_input(toggle)
	verify(scene.grass_profile.cells.size()==8 and scene.grass_material.get_shader_parameter("painted_grass"),"eight generated grass silhouettes restore with J")
	var roots_clear := true
	var root_image: Image = scene.trees[0].visual.texture.get_image()
	var visible_bottom := 0
	for y in range(root_image.get_height()-1,-1,-1):
		for x in root_image.get_width():
			if root_image.get_pixel(x,y).a>=.5:
				visible_bottom = y+1
				break
		if visible_bottom>0: break
	for tree in scene.trees:
		var visual: Sprite3D = tree.visual
		var foot: float = visual.offset.y+visual.texture.get_height()/2.
		roots_clear = roots_clear and foot>=visible_bottom
	verify(roots_clear,"tree anchors place every opaque root tip above the ground")
	var posts_hidden := true
	for post in scene.reference_posts: posts_hidden = posts_hidden and not post.visible and post.get_child(0).collision_layer==0
	verify(posts_hidden,"reference posts are hidden and no longer block walking")
	scene.teleport(Vector3(0,0,5))
	for i in 12: await physics_frame
	# Occlusion changes presentation, never the trunk collision.
	var tree: Dictionary = scene.trees[0]
	scene.hero.position = tree.root.position+Vector3(0,0,-.8)
	scene._update_camera(0,true)
	scene._update_occlusion(1.)
	verify(float(tree.visual.material_override.get_shader_parameter("fade"))<.3,"tree cutout fades when it covers the character")
	scene.hero.position = Vector3(0,0,5)
	scene._update_camera(0,true)
	scene._update_occlusion(1.)
	verify(is_equal_approx(float(tree.visual.material_override.get_shader_parameter("fade")),1.),"tree opacity recovers after leaving occlusion")
	print(JSON.stringify({"checks":checks,"failures":failures}))
	quit(0 if failures.is_empty() else 1)
