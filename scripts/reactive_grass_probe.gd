extends SceneTree
var failures: Array[String] = []
var checks := 0
func _initialize() -> void:
	_run.call_deferred()
func verify(value: bool,message: String) -> void:
	checks += 1
	if not value: failures.append(message)
	print("PASS " if value else "FAIL ",message)
func snapshot() -> Image:
	await process_frame
	await process_frame
	await RenderingServer.frame_post_draw
	return root.get_texture().get_image()
func changed(a: Image,b: Image,area: Rect2i) -> int:
	var result := 0
	for y in range(area.position.y,area.end.y):
		for x in range(area.position.x,area.end.x):
			if a.get_pixel(x,y)!=b.get_pixel(x,y): result += 1
	return result
func _run() -> void:
	var scene: Node2D = load("res://scenes/world/world_restart.tscn").instantiate()
	scene.grass_count = 420
	scene.grass_enabled = true
	root.add_child(scene)
	await process_frame
	await physics_frame
	await physics_frame
	var field: Node = scene.grass_field
	verify(field.tufts.size()==420,"mechanics sandbox builds exactly 420 placeholder grass tufts")
	var cheap := true
	var shared := true
	for tuft in field.tufts:
		cheap = cheap and tuft.get_child_count()==0 and tuft.get_script()==null and tuft.z_index==0
		shared = shared and tuft.material==field.shared_material and tuft.get_parent()==scene.world
	verify(cheap,"no per-tuft physics bodies, scripts or projectors")
	verify(shared and scene.world.y_sort_enabled,"shared material and real foot sorting with player")
	var light: Resource = scene.rig.profile
	var position: Vector2 = field.tufts[0].position
	var key := InputEventKey.new()
	key.pressed = true
	key.physical_keycode = KEY_P
	scene._unhandled_key_input(key)
	verify(scene.rig.profile==light and field.tufts[0].position==position,"P changes neither light nor vegetation placement")
	scene._unhandled_key_input(key)
	key.physical_keycode = KEY_G
	scene._unhandled_key_input(key)
	verify(not field.active and not field.tufts[0].visible and not field.is_processing(),"G removes grass rendering and update work")
	scene._unhandled_key_input(key)
	verify(field.active and field.tufts[0].visible,"G restores same grass stands")
	var hero: CharacterBody2D = scene.hero
	hero.set_physics_process(false)
	hero.position = Vector2(1140,1295)*scene.layout_scale
	hero.reset_physics_interpolation()
	verify(hero.move_and_collide(Vector2(90,0)*scene.layout_scale)==null,"actual player crosses the dense grass trial without blocking")
	# Verify actual shader deformation in OpenGL, with wind/camera/lighting frozen.
	scene.set_process(false)
	scene.set_physics_process(false)
	scene.rig.set_process(false)
	field.set_process(false)
	scene.label.get_parent().visible = false
	scene.guide_layer.hide()
	scene.solar_union.display.hide()
	scene.hero_local_shadow.hide()
	for prop in scene.registered_props: prop.local_projection.hide()
	for prop in scene.world.get_children():
		if prop.has_method("effective_footprint") and prop.visual is Sprite2D and prop.visual.material:
			if prop.visual.material.shader==preload("res://scripts/art/garden_foliage.gdshader"):
				prop.visual.material.set_shader_parameter("strength",0.0)
	hero.hide()
	var center: Vector2 = Vector2(1185,1295)*scene.layout_scale
	scene.camera.position = center+Vector2(0,-20)
	scene.camera.zoom = Vector2.ONE*2.15
	scene.camera.reset_physics_interpolation()
	scene.camera.force_update_scroll()
	field.shared_material.set_shader_parameter("wind",0.0)
	hero.position = center+Vector2(150,0)
	hero.reset_physics_interpolation()
	field.clear_trail()
	field.update_interaction(0)
	var before: Image = await snapshot()
	hero.position = center
	hero.reset_physics_interpolation()
	field.update_interaction(0)
	var pressed: Image = await snapshot()
	hero.position = center+Vector2(150,0)
	hero.reset_physics_interpolation()
	field.update_interaction(2.0)
	var recovered: Image = await snapshot()
	var screen: Vector2 = scene.get_viewport().canvas_transform*center
	screen *= Vector2(before.get_size())/scene.get_viewport_rect().size
	var area := Rect2i(Vector2i(screen)-Vector2i(48,48),Vector2i(96,96))
	area = area.intersection(Rect2i(Vector2i.ZERO,before.get_size()))
	var bent_pixels := changed(before,pressed,area)
	var recovery_pixels := changed(before,recovered,area)
	verify(bent_pixels>20,"real render reacts to footsteps: changed pixels="+str(bent_pixels))
	verify(recovery_pixels==0,"grass returns to resting shape after departure: changed pixels="+str(recovery_pixels))
	before.save_png("res://docs/captures/world_restart/grass05_rest.png")
	pressed.save_png("res://docs/captures/world_restart/grass05_pressed.png")
	recovered.save_png("res://docs/captures/world_restart/grass05_recovered.png")
	print("REACTIVE_GRASS_PROBE ",checks-failures.size(),"/",checks," failures=",failures)
	quit(0 if failures.is_empty() else 1)
