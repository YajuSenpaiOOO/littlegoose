extends "res://scripts/world/woodland46_probe.gd"
class RouteSample:
	extends "res://scripts/world/world50.gd"
	func _hero_script() -> Script: return LivingActor
	func fire_input_held() -> bool: return false

func shot50(name: String) -> Image:
	var image: Image=await snapshot()
	image.save_png("res://docs/captures/world_restart/route50_"+name+".png")
	return image

func run() -> void:
	var sample: Node3D=RouteSample.new()
	root.add_child(sample)
	while not is_instance_valid(sample.porch49): await physics_frame
	for i in 40: await physics_frame
	sample.hero.controls_enabled=false
	sample.label.get_parent().hide()
	var light: Node3D=sample.porch49
	verify(RenderingServer.get_current_rendering_method()=="gl_compatibility","Compatibility retained")
	verify(light.field_data.openings.size()>=3 and light.field_texture.get_width()==320,"route uses a baked atlas with generated openings")
	verify(not light.has_node("DoorstepVolume") and sample.garden.material_stage==1,"intact house and original stones retained")
	var metadata_ok := false
	var baker=preload("res://scripts/art/route_light_baker50.gd").new()
	for route in sample.meadow.named_routes:
		if route.name==light.palette.route_name: baker.prepare(route.points,light.palette)
	var recorded: Array=light.field_data.openings[2].at
	metadata_ok=baker.openings[2].at.distance_to(Vector2(recorded[0],recorded[1]))<.0001
	verify(metadata_ok,"same palette and route reproduce saved opening positions")
	var alternate: Resource=light.palette.duplicate()
	alternate.seed_value+=1
	baker.prepare(baker.points,alternate)
	verify(baker.openings[2].at.distance_to(Vector2(recorded[0],recorded[1]))>.1,"another seed creates a different reusable layout")
	sample._travel_region("home")
	for i in 25: await physics_frame
	paused=true
	light.set_profile(0)
	var home_before: Image=await shot50("home_original")
	light.set_profile(2)
	var home_after: Image=await shot50("home")
	var center: Vector2i=Vector2i(sample.camera.unproject_position(sample.house_art.global_position+Vector3.UP*2.))
	verify(changed(home_before,home_after,Rect2i(center-Vector2i(90,100),Vector2i(180,200)))<100,"approved central house lighting stays unchanged")
	paused=false
	sample._travel_region("trail")
	for i in 30: await physics_frame
	var camera_before: Transform3D=sample.camera.transform
	paused=true
	var images: Array[Image]=[]
	for i in 3:
		light.set_profile(i)
		images.append(await shot50("trail%d"%i))
		verify(camera_before==sample.camera.transform,"profile %d preserves camera"%i)
	verify(changed(images[0],images[2],Rect2i(Vector2i.ZERO,images[0].get_size()))>100000,"route lighting visibly changes the same rendered view")
	light.set_profile(0)
	var restored: Image=await snapshot()
	verify(changed(restored,images[0],Rect2i(Vector2i.ZERO,restored.get_size()))<100,"route comparison restores without residual shading")
	light.set_profile(2)
	paused=false
	var opening: Array=light.field_data.openings[2].at
	sample._teleport15(Vector2(opening[0],opening[1]))
	for i in 25: await physics_frame
	await shot50("opening")
	var sun_color: Color=sample.hero.visual.modulate
	sample._travel_region("trail")
	for i in 25: await physics_frame
	verify(sample.hero.visual.modulate.g<sun_color.g,"hero receives the same bright-to-shade transition")
	sample._teleport15(sample.meadow.main_route[1])
	sample.hero.controls_enabled=true
	var route_ok := true
	for i in range(2,7):
		if not await walk_to(sample,sample.meadow.main_route[i]): route_ok=false; break
	verify(route_ok,"actual player walks the courtyard-to-forest route")
	sample.hero.controls_enabled=false
	sample.start_combat()
	for enemy in sample.enemies: enemy.active_ai=false
	for i in 12: await physics_frame
	verify(sample.enemies.size()==1 and sample.round_index==0,"first-wave combat retained")
	sample.hurt_flash=.2
	light._update_actor()
	verify(sample.hero.visual.modulate.r>sample.hero.visual.modulate.g*1.8,"regional actor lighting retains damage flash")
	var output := FileAccess.open("res://docs/route50-validation.json",FileAccess.WRITE)
	output.store_string(JSON.stringify({"checks":checks,"failures":failures,"openings":light.field_data.openings.size(),"shader_variants":light.shader_cache.size()},"\t"))
	print("ROUTE50 ",checks," checks; failures=",failures.size())
	quit(0 if failures.is_empty() else 1)
