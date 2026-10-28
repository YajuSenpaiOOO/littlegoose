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
	var scene: Node2D = load("res://scenes/sandbox/home_pixel_study.tscn").instantiate()
	root.add_child(scene)
	await process_frame
	await process_frame
	scene.hero.frozen = true
	var tree: Node2D = scene.world.get_node("Tree10")
	var painted_root: Vector2 = tree.visual.to_global(Vector2(38,78))
	verify(painted_root.distance_to(tree.global_position)<0.01,"broadleaf painted trunk and sorting origin coincide")
	scene.hero.position = tree.position+Vector2(-35,-3)
	for i in 45:
		await physics_frame
		scene.hero.velocity = Vector2(78.3,0)
		scene.hero.move_and_slide()
	verify(scene.hero.position.x<tree.position.x-15 and scene.hero.position.x>tree.position.x-20,"broadleaf collision stops the hero at the painted trunk")
	verify(scene.solar_union.count==scene.registered_props.size()+2 and scene.solar_union.casters.get_child_count()==scene.solar_union.count,"all old and new sun casters share one coverage mask")
	verify(scene.solar_union.display.z_index==-2,"merged sunlight shade stays under standing props")
	var rig: Node2D = scene.rig
	rig.set_process(false)
	rig.set_profile(load("res://assets/world_lighting_v1/sunset.tres"),true)
	var azimuth: float = rig.current_azimuth
	var epoch: int = rig.projection_epoch
	var key := InputEventKey.new()
	key.physical_keycode = KEY_N
	key.pressed = true
	scene.sky_index = 0
	scene._unhandled_key_input(key)
	var continuous := true
	var visible_throughout := true
	var matches_station := true
	var expected_azimuth := azimuth
	var expected_elevation := 16.0
	var expected_opacity := 0.27
	for i in 151:
		var weight := 1.0-exp(-5.0/60.0)
		expected_azimuth = lerp_angle(expected_azimuth,deg_to_rad(58.0),weight)
		expected_elevation = lerpf(expected_elevation,67.0,weight)
		expected_opacity = lerpf(expected_opacity,0.3,weight)
		rig.advance(1.0/60.0)
		if i<149:
			matches_station = matches_station and absf(angle_difference(expected_azimuth,rig.current_azimuth))<0.00001 and absf(expected_elevation-rig.current_elevation)<0.0001 and absf(expected_opacity-rig.current_opacity)<0.00001
		continuous = continuous and absf(angle_difference(azimuth,rig.current_azimuth))<0.13
		visible_throughout = visible_throughout and rig.current_opacity>=0.269
		azimuth = rig.current_azimuth
	verify(continuous and rig.projection_epoch==epoch and matches_station,"N follows the station exponential direction, elevation and opacity curve")
	verify(visible_throughout,"daylight-to-daylight transition never hides the shadow")
	verify(is_equal_approx(rig.current_elevation,67.0) and is_equal_approx(rig.current_opacity,0.3),"station transition settles at the exact noon preset after 2.5 seconds")
	rig.set_profile(load("res://assets/world_lighting_v1/night.tres"))
	rig.advance(0.3)
	var before: float = rig.current_opacity
	rig.set_profile(load("res://assets/world_lighting_v1/dawn.tres"))
	verify(is_equal_approx(before,rig.current_opacity),"rapid preset input continues from current opacity without a jump")
	print("SHADOW_REVISION_PROBE ",checks-failures,"/",checks," passed")
	scene.queue_free()
	await process_frame
	quit(0 if failures==0 else 1)
