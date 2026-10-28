extends "res://scripts/world/woodland46_probe.gd"
class SpotSample:
	extends "res://scripts/world/world58.gd"
	func _hero_script() -> Script: return LivingActor
	func fire_input_held() -> bool: return false

func shot58(name: String) -> Image:
	var image: Image=await snapshot()
	image.save_png("res://docs/captures/world_restart/spot58_"+name+".png")
	return image

func run() -> void:
	var sample: Node3D=SpotSample.new()
	root.add_child(sample)
	while not is_instance_valid(sample.time55) or not sample.time55.is_node_ready(): await physics_frame
	for i in 35: await physics_frame
	sample.hero.controls_enabled=false
	sample.label.get_parent().hide()
	var time: Node=sample.time55
	var accents: Node3D=time.accents57
	var fill: Node3D=sample.porch49
	var focus: ShaderMaterial=sample.atmosphere41.focus_material
	verify(time.selected_rig58==0 and not fill.fill_enabled,"default rig is spotlight only")
	verify(sample.meadow.get_script().resource_path=="res://scripts/world/world_surface21.gd" and RenderingServer.get_current_rendering_method()=="gl_compatibility","original terrain and Compatibility retained")
	time.preview_at(22.)
	time.visual_hour=22.
	accents.fireflies_enabled=false
	time.apply_look()
	for i in 10: await physics_frame
	paused=true
	var camera_before: Transform3D=sample.camera.transform
	verify(not fill.warm_light.visible and fill.warm_light.light_energy==0. and fill.fill_strength==0.,"old body light and its tint gain are fully disabled")
	verify(accents.stage_light.visible and not accents.stage_light.shadow_enabled and not accents.stage_beam.visible,"one spotlight remains; old intersecting beam card is hidden")
	var spot: Image=await shot58("home_spot_only")
	var area := Rect2i(Vector2i.ZERO,spot.get_size())
	focus.set_shader_parameter("cone_density58",0.)
	var no_air: Image=await shot58("home_pool_only")
	verify(changed(spot,no_air,area)>500,"soft cone changes actual scenery, beyond just a ground pool")
	focus.set_shader_parameter("cone_density58",.28)
	time.set_rig58(1)
	var body: Image=await shot58("home_body_only")
	verify(fill.fill_enabled and not accents.stage_light.visible and focus.get_shader_parameter("actor_stage57")==0.,"body-only rig removes spotlight and stage grade together")
	time.set_rig58(2)
	var both: Image=await shot58("home_both")
	verify(fill.fill_enabled and accents.stage_light.visible,"combined rig remains available for comparison")
	verify(changed(spot,body,area)>500 and changed(spot,both,area)>100,"separate rigs visibly differ")
	verify(sample.camera.transform==camera_before,"light comparisons keep camera and layout fixed")
	time.set_rig58(0)
	sample.hurt_flash=.2
	fill._update_actor()
	verify(sample.hero.visual.modulate.r>sample.hero.visual.modulate.g*1.8,"spot-only preserves damage feedback")
	sample.hurt_flash=0.
	time.visual_hour=12.
	time.apply_look()
	verify(not accents.stage_light.visible and not fill.warm_light.visible,"spot-only has no automatic daytime body halo")
	paused=false
	sample._travel_region("trail")
	time.preview_at(22.)
	time.visual_hour=22.
	time.apply_look()
	for i in 30: await physics_frame
	paused=true
	time.apply_look()
	var trail: Image=await shot58("trail_spot_only")
	focus.set_shader_parameter("cone_density58",0.)
	var clear: Image=await shot58("trail_pool_only")
	var bounds: Vector4=focus.get_shader_parameter("cone_bounds58")
	var size := Vector2(trail.get_size())
	var foot: Vector2=sample.camera.unproject_position(sample.hero.global_position)/sample.get_viewport().get_visible_rect().size*size
	var left := Rect2i(Vector2i(Vector2(bounds.x,bounds.y)*size),Vector2i(Vector2(foot.x-bounds.x*size.x,(bounds.w-bounds.y)*size.y)))
	var right := Rect2i(Vector2i(foot.x,bounds.y*size.y),Vector2i(bounds.z*size.x-foot.x,(bounds.w-bounds.y)*size.y))
	left=left.intersection(area)
	right=right.intersection(area)
	var left_changes := changed(trail,clear,left)
	var right_changes := changed(trail,clear,right)
	verify(left_changes>100 and right_changes>100,"cone volume is visible on both sides of the central light axis")
	focus.set_shader_parameter("cone_density58",.28)
	accents.stage_enabled=false
	time.apply_look()
	focus.set_shader_parameter("near_blur58",1.)
	var near_on: Image=await shot58("near_blur_on")
	focus.set_shader_parameter("near_blur58",0.)
	var near_off: Image=await shot58("near_blur_off")
	var near_changes := changed(near_on,near_off,area)
	verify(near_changes>100,"existing near depth-of-field changes actual foreground pixels")
	var hero_point: Vector2=sample.camera.unproject_position(sample.hero.global_position+Vector3.UP*.85)/sample.get_viewport().get_visible_rect().size*size
	verify(changed(near_on,near_off,Rect2i(Vector2i(hero_point)-Vector2i(10,10),Vector2i(20,20)))<10,"near blur leaves the focused actor clear")
	focus.set_shader_parameter("near_blur58",1.)
	time.set_rig58(0)
	verify(accents.flies.size()==32 and not sample.hero_contact.visible,"pooled fireflies and original silhouette shadow retained")
	var file := FileAccess.open("res://docs/spot58-validation.json",FileAccess.WRITE)
	file.store_string(JSON.stringify({"checks":checks,"failures":failures,"cone_left_pixels":left_changes,"cone_right_pixels":right_changes,"near_blur_pixels":near_changes},"\t"))
	print("SPOT58 ",checks," checks; failures=",failures.size())
	quit(0 if failures.is_empty() else 1)
