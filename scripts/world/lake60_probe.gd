extends "res://scripts/world/woodland46_probe.gd"
class LakeSample:
	extends "res://scripts/world/world60.gd"
	func _hero_script() -> Script: return LivingActor
	func fire_input_held() -> bool: return false

func shot60(tag: String) -> Image:
	var frame: Image=await snapshot()
	frame.save_png("res://docs/captures/world_restart/lake60_"+tag+".png")
	return frame

func run() -> void:
	var sample: Node3D=LakeSample.new()
	root.add_child(sample)
	while not is_instance_valid(sample.bridge59) or not sample.bridge59.is_node_ready(): await physics_frame
	for i in 35: await physics_frame
	sample.label.get_parent().hide()
	sample.hero.controls_enabled=false
	var study: Node3D=sample.bridge59
	var water: ShaderMaterial=sample.water_material19
	var collision: Shape3D=sample.bridge_collision.shape
	verify(RenderingServer.get_current_rendering_method()=="gl_compatibility","Compatibility retained")
	verify(water.get_shader_parameter("water_paint59") is Texture2D and water.get_shader_parameter("shore59") is Texture2D,"paint and shore mask survive shader replacement")
	var surfaces := 0
	for child in sample.get_children():
		if child is MeshInstance3D and child.name=="LakeSurface":
			surfaces+=1
			verify(is_equal_approx(child.position.y,-.40),"lake lowered 0.4m")
	verify(surfaces>0 and is_equal_approx(study._shore_water_height(),-.655),"shore follows lower water")
	sample.time55.preview_at(12.)
	sample.time55.visual_hour=12.
	sample.time55.apply_look()
	study._process(0.)
	for i in 15: await physics_frame
	paused=true
	water.set_shader_parameter("clock",10.)
	var a: Image=await shot60("noon_t10")
	water.set_shader_parameter("clock",12.)
	var b: Image=await shot60("noon_t12")
	var water_area := Rect2i(650,680,650,180)
	var animated_pixels: int=changed(a,b,water_area)
	verify(animated_pixels>8000,"water visibly moves in a two second interval")
	study.set_motion(false)
	var frozen: Image=await shot60("frozen_a")
	water.set_shader_parameter("clock",20.)
	var frozen_b: Image=await shot60("frozen_b")
	verify(changed(frozen,frozen_b,water_area)==0,"motion toggle freezes water completely")
	study.set_motion(true)
	water.set_shader_parameter("clock",10.)
	study.set_sparkles(false)
	var dull: Image=await shot60("no_sparkles")
	verify(changed(a,dull,water_area)>500,"sparkles are visible independently of base water movement")
	study.set_sparkles(true)
	study.set_water(2)
	var key := InputEventKey.new()
	key.pressed=true; key.alt_pressed=true; key.physical_keycode=KEY_7
	sample._unhandled_input(key)
	verify(study.bridge_style==2 and study.water_style==2,"Alt7 preserves selected water")
	study.set_water(0)
	await shot60("stone_noon")
	key.physical_keycode=KEY_5
	sample._unhandled_input(key)
	verify(study.bridge_style==0 and study.water_style==0,"Alt5 changes only bridge")
	for hour in [17.5,22.]:
		sample.time55.visual_hour=hour
		sample.time55.apply_look()
		study._process(0.)
		await shot60("hour_"+str(hour))
	verify(sample.bridge_collision.shape==collision,"water does not rebuild bridge collision")
	verify(sample.meadow.get_script().resource_path=="res://scripts/world/world_surface21.gd","terrain retained")
	sample.label.get_parent().show()
	sample.time55.update_guide()
	await shot60("guide")
	var file := FileAccess.open("res://docs/lake60-validation.json",FileAccess.WRITE)
	file.store_string(JSON.stringify({"checks":checks,"failures":failures,"animated_water_pixels":animated_pixels},"\t"))
	print("LAKE60 ",checks," checks; failures=",failures.size())
	quit(0 if failures.is_empty() else 1)
