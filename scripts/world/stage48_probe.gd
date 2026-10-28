extends "res://scripts/world/woodland46_probe.gd"
class StageSample:
	extends "res://scripts/world/world48.gd"
	func _hero_script() -> Script: return LivingActor
	func fire_input_held() -> bool: return false

func capture48(name: String) -> Image:
	var shot: Image=await snapshot()
	shot.save_png("res://docs/captures/world_restart/stage48_"+name+".png")
	return shot

func run() -> void:
	var sample: Node3D=StageSample.new()
	root.add_child(sample)
	while not is_instance_valid(sample.lighting47): await physics_frame
	for i in 40: await physics_frame
	sample.hero.controls_enabled=false
	sample._travel_region("home")
	for i in 25: await physics_frame
	sample.label.get_parent().hide()
	var light: Node=sample.lighting47
	var atmosphere: Node3D=sample.atmosphere41
	verify(RenderingServer.get_current_rendering_method()=="gl_compatibility" and atmosphere.focus_level==2,"Compatibility and approved depth of field are retained")
	verify(sample.garden.material_stage==1 and is_equal_approx(sample.woodland_life.lantern_root.get_child(0).pixel_size*1376.,2.65),"original stone and the taller grounded lamp remain unchanged")
	verify(light.glow_rects.size()==4,"three windows and one lantern have projected local glow masks")
	var camera_before: Transform3D=sample.camera.transform
	var hero_before: Vector3=sample.hero.position
	paused=true
	var images: Array[Image]=[]
	for i in 3:
		light.set_profile(i)
		light._update_glow_rects()
		images.append(await capture48("home%d"%i))
		verify(sample.camera.transform==camera_before and sample.hero.position==hero_before,"stage %d preserves camera framing and actor position"%i)
		verify(is_equal_approx(atmosphere.environment.fog_depth_end,light.base.fog_depth_end) and not atmosphere.shafts.visible,"stage %d retains original distant air and disables rejected fog/ribbons"%i)
	var area := Rect2i(Vector2i.ZERO,images[0].get_size())
	verify(changed(images[0],images[1],area)>10000,"depth-based staging visibly separates foreground and background")
	verify(changed(images[1],images[2],area)>100,"local lamp and window softness visibly changes the rendered image")
	var face: Vector2i=Vector2i(sample.camera.unproject_position(sample.hero.position+Vector3.UP*.85))
	var feet: Vector2i=Vector2i(sample.camera.unproject_position(sample.hero.position))
	verify(changed(images[0],images[2],Rect2i(face-Vector2i(16,20),Vector2i(32,40)))==0,"middle-plane hero remains crisp and receives no blanket color or white halo")
	verify(changed(images[0],images[2],Rect2i(feet-Vector2i(10,0),Vector2i(20,8)))==0,"contact beneath the player's feet remains unchanged")
	light.set_profile(0)
	var restored: Image=await snapshot()
	verify(changed(images[0],restored,area)<100,"original image is restored without leaving grading or halo behind")
	light.set_profile(2)
	atmosphere._set_focus_level(0)
	verify(atmosphere.focus_card.visible and not atmosphere.focus_enabled,"staging and local glow still work when blur is switched off")
	atmosphere._set_focus_level(2)
	paused=false
	sample._teleport15(Vector2(.88,-2.7))
	for i in 25: await physics_frame
	paused=true
	for i in 3:
		light.set_profile(i)
		light._update_glow_rects()
		await capture48("garden%d"%i)
	paused=false
	sample._teleport15(Vector2(-4.6,.7))
	sample.hero.controls_enabled=true
	verify(await walk_to(sample,Vector2(-4.6,-2.6)),"actual player still walks through the open courtyard")
	sample.hero.controls_enabled=false
	light.set_profile(2)
	sample.start_combat()
	for enemy in sample.enemies: enemy.active_ai=false
	for i in 12: await physics_frame
	verify(sample.enemies.size()==1 and sample.round_index==0,"existing first-wave combat still starts")
	var output := FileAccess.open("res://docs/stage48-validation.json",FileAccess.WRITE)
	output.store_string(JSON.stringify({"checks":checks,"failures":failures,"profiles":light.LABELS48},"\t"))
	print("STAGE48 ",checks," checks; failures=",failures.size())
	quit(0 if failures.is_empty() else 1)
