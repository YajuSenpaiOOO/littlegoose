extends "res://scripts/ground_lab_probe.gd"

func capture(name: String) -> void:
	var shot: Image=await snapshot()
	shot.save_png("res://docs/captures/world_restart/garden45_"+name+".png")

func run() -> void:
	var sample: Node3D=load("res://scenes/world/world45.tscn").instantiate()
	root.add_child(sample)
	while not is_instance_valid(sample.garden): await physics_frame
	for i in 35: await physics_frame
	sample.hero.controls_enabled=false
	sample._travel_region("home")
	for i in 30: await physics_frame
	sample.label.get_parent().hide()
	var garden: Node3D=sample.garden
	var camera_before: Transform3D=sample.camera.transform
	var actor_before: Vector3=sample.hero.position
	var body_before: Transform3D=garden.bodies[0].transform
	verify(RenderingServer.get_current_rendering_method()=="gl_compatibility" and sample.atmosphere41.focus_level==2,"Compatibility and approved strong focus stay active")
	verify(garden.material_stage==1 and garden.stone_materials.size()==32,"approved plain stone is default and all 32 stones retain comparison materials")
	verify(garden.shadow_targets.size()>=40 and garden.contacts.size()>=26,"crops, shrubs, flowers and kickable stones have fitted shadow targets")
	await capture("home")
	for i in 3:
		garden.set_material_stage(i)
		verify(garden.material_stage==i and garden.bodies[0].transform==body_before and sample.hero.position.distance_to(actor_before)<.01,"material stage %d preserves the same physical layout"%i)
		await capture("material%d"%i)
	verify(sample.camera.transform.origin.distance_to(camera_before.origin)<.05,"material comparison preserves camera framing")
	garden.set_material_stage(2)
	sample._teleport15(Vector2(.88,-2.7))
	for i in 30: await physics_frame
	paused=true
	garden.set_shadows(false)
	var off := true
	for target in garden.shadow_targets: off=off and target.cast_shadow==GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	for contact in garden.contacts: off=off and not contact.visible
	verify(off,"new small-prop shadows switch off without disabling structural shadows")
	await capture("shadow_off")
	var before_shadow: Image=await snapshot()
	garden.set_shadows(true)
	var on := true
	for target in garden.shadow_targets: on=on and target.cast_shadow==GeometryInstance3D.SHADOW_CASTING_SETTING_DOUBLE_SIDED
	for contact in garden.contacts: on=on and contact.visible
	verify(on,"alpha-cutout shadows and soft root contact switch back on")
	await capture("shadow_on")
	for contact in garden.contacts: contact.visible=false
	var native_shadow: Image=await snapshot()
	var difference: int=changed(before_shadow,native_shadow,Rect2i(Vector2i.ZERO,native_shadow.get_size()))
	verify(difference>50,"real alpha-cutout shadows visibly change the rendered scene (%d pixels)"%difference)
	for contact in garden.contacts: contact.visible=true
	paused=false
	var output := FileAccess.open("res://docs/garden45-validation.json",FileAccess.WRITE)
	output.store_string(JSON.stringify({"checks":checks,"failures":failures,"shadow_targets":garden.shadow_targets.size(),"contacts":garden.contacts.size()},"\t"))
	print("GARDEN45 ",checks," checks; failures=",failures.size())
	quit(0 if failures.is_empty() else 1)
