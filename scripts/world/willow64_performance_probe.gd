extends "res://scripts/world/air52_performance_probe.gd"
class WillowPerfSample:
	extends "res://scripts/world/world64.gd"
	func _hero_script() -> Script: return LivingActor
	func fire_input_held() -> bool: return false

func run() -> void:
	var sample: Node3D=WillowPerfSample.new()
	root.add_child(sample)
	while not is_instance_valid(sample.landmark62) or not sample.landmark62.is_node_ready(): await physics_frame
	sample.label.get_parent().hide()
	sample.hero.controls_enabled=false
	sample.time55.preview_at(12.)
	sample.time55.visual_hour=12.
	sample.time55.apply_look()
	sample.go_roots64()
	for i in 50: await physics_frame
	var results := []
	for enabled in [false,true,true,false]:
		sample.landmark62.set_understory(enabled)
		for i in 20: await process_frame
		var result: Dictionary=await record(sample,180,false)
		result.understory=enabled
		result.draw_calls=Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME)
		results.append(result)
		print("WILLOW64_PERF ",JSON.stringify(result))
	var file := FileAccess.open("res://docs/willow64-performance.json",FileAccess.WRITE)
	file.store_string(JSON.stringify({"frames_per_segment":180,"order":"ABBA, close-root normal camera, seated roots always on","results":results},"\t"))
	sample.landmark62.set_understory(true)
	sample.label.get_parent().show()
	sample.time55.update_guide()
	var frame: Image=await snapshot()
	frame.save_png("res://docs/captures/world_restart/willow64_guide.png")
	quit()
