extends "res://scripts/world/air52_performance_probe.gd"
class LandmarkPerfSample:
	extends "res://scripts/world/world62.gd"
	func _hero_script() -> Script: return LivingActor
	func fire_input_held() -> bool: return false

func run() -> void:
	var sample: Node3D=LandmarkPerfSample.new()
	root.add_child(sample)
	while not is_instance_valid(sample.landmark62) or not sample.landmark62.is_node_ready(): await physics_frame
	sample.label.get_parent().hide()
	sample.hero.controls_enabled=false
	sample.time55.preview_at(12.)
	sample.time55.visual_hour=12.
	sample.time55.apply_look()
	for i in 45: await physics_frame
	var results := []
	for style in [-1,0,1,2]:
		if style<0: sample.landmark62.set_old_tree(true)
		else: sample.landmark62.set_tree(style)
		for i in 20: await process_frame
		var result: Dictionary=await record(sample,180,false)
		result.variant=style
		result.draw_calls=Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME)
		results.append(result)
		print("LANDMARK62_PERF ",JSON.stringify(result))
	var file := FileAccess.open("res://docs/landmark62-performance.json",FileAccess.WRITE)
	file.store_string(JSON.stringify({"frames_per_variant":180,"camera":"temporary full tree review; same light, painted sign, no water animation","results":results},"\t"))
	sample.landmark62.set_tree(0)
	sample.go_sign62()
	for i in 40: await physics_frame
	var sign_frame: Image=await snapshot()
	sign_frame.save_png("res://docs/captures/world_restart/landmark62_sign_final.png")
	sample.go_tree62()
	for i in 40: await physics_frame
	sample.label.get_parent().show()
	sample.time55.update_guide()
	var guide_frame: Image=await snapshot()
	guide_frame.save_png("res://docs/captures/world_restart/landmark62_guide.png")
	quit()
