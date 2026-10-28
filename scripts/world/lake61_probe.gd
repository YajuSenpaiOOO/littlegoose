extends "res://scripts/world/woodland46_probe.gd"
class LakeSample:
	extends "res://scripts/world/world61.gd"
	func _hero_script() -> Script: return LivingActor
	func fire_input_held() -> bool: return false

func shot61(tag: String) -> Image:
	var frame: Image=await snapshot()
	frame.save_png("res://docs/captures/world_restart/lake61_"+tag+".png")
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
	verify(study.bridge_style==0 and study.water_style==0,"default rope bridge and storybook water")
	sample.time55.preview_at(12.)
	sample.time55.visual_hour=12.
	sample.time55.apply_look()
	for i in 15: await physics_frame
	study._process(0.)
	paused=true
	water.set_shader_parameter("clock",10.)
	study.set_distant_glow(false)
	var off: Image=await shot61("off")
	study.set_distant_glow(true)
	var on: Image=await shot61("on")
	var near_area := Rect2i(650,680,650,180)
	var far_area := Rect2i(1200,130,200,100)
	var near_changed: int=changed(off,on,near_area)
	var far_changed: int=changed(off,on,far_area)
	verify(near_changed==0,"near water remains pixel identical")
	verify(far_changed>1000,"distant highlights visibly change")
	water.shader=preload("res://scripts/art/lake60.gdshader")
	var old: Image=await shot61("old60")
	verify(changed(off,old,Rect2i(Vector2i.ZERO,old.get_size()))==0,"off matches old60 shader exactly")
	water.shader=preload("res://scripts/art/lake61.gdshader")
	study._process(0.)
	study.set_distant_glow(true)
	water.set_shader_parameter("clock",12.)
	var next: Image=await shot61("t12")
	verify(changed(on,next,far_area)>1000,"distant light animates")
	study.set_sparkles(false)
	var no_sparkles: Image=await shot61("no_sparkles")
	study.set_distant_glow(false)
	var both_off: Image=await shot61("both_off")
	verify(changed(no_sparkles,both_off,far_area)==0,"sparkle toggle disables distant and near glints")
	study.set_sparkles(true)
	study.set_distant_glow(true)
	for hour in [17.5,22.]:
		sample.time55.visual_hour=hour
		sample.time55.apply_look()
		study._process(0.)
		await shot61("hour_"+str(hour))
	var key := InputEventKey.new()
	key.pressed=true; key.alt_pressed=true; key.physical_keycode=KEY_V
	sample._unhandled_input(key)
	verify(not study.distant_glow,"AltV toggles distant treatment")
	var file := FileAccess.open("res://docs/lake61-validation.json",FileAccess.WRITE)
	file.store_string(JSON.stringify({"checks":checks,"failures":failures,"near_changed":near_changed,"far_changed":far_changed,"focus":water.get_shader_parameter("focus61")},"\t"))
	print("LAKE61 ",checks," checks; failures=",failures.size())
	quit(0 if failures.is_empty() else 1)
