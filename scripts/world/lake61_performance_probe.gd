extends "res://scripts/world/air52_performance_probe.gd"
class LakePerfSample:
	extends "res://scripts/world/world61.gd"
	func _hero_script() -> Script: return LivingActor
	func fire_input_held() -> bool: return false

func run() -> void:
	var sample: Node3D=LakePerfSample.new()
	root.add_child(sample)
	while not is_instance_valid(sample.bridge59) or not sample.bridge59.is_node_ready(): await physics_frame
	sample.label.get_parent().hide()
	sample.hero.controls_enabled=false
	sample.time55.preview_at(12.)
	sample.time55.visual_hour=12.
	sample.time55.apply_look()
	for i in 60: await physics_frame
	var active: Shader=preload("res://scripts/art/lake61.gdshader")
	var baseline: Shader=preload("res://scripts/art/lake60.gdshader")
	var results := []
	# ABBA order reduces the bias from shader warmup and other background work.
	for mode in ["near60","distant61","distant61","near60"]:
		sample.water_material19.shader=baseline if mode=="near60" else active
		for i in 30: await process_frame
		var result: Dictionary=await record(sample,240,false)
		result.mode=mode
		result.draw_calls=Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME)
		results.append(result)
		print("LAKE61_PERF ",JSON.stringify(result))
	var file := FileAccess.open("res://docs/lake61-performance.json",FileAccess.WRITE)
	file.store_string(JSON.stringify({"frames_per_segment":240,"order":"ABBA; identical lower lake and bridge; near60 vs animated60 shader","results":results},"\t"))
	quit()

