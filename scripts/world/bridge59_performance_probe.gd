extends "res://scripts/world/air52_performance_probe.gd"
class BridgePerfSample:
	extends "res://scripts/world/world59.gd"
	func _hero_script() -> Script: return LivingActor
	func fire_input_held() -> bool: return false
func run() -> void:
	var sample: Node3D=BridgePerfSample.new()
	root.add_child(sample)
	while not is_instance_valid(sample.bridge59) or not sample.bridge59.is_node_ready(): await physics_frame
	sample.label.get_parent().hide()
	sample.hero.controls_enabled=false
	sample.time55.preview_at(12.)
	sample.time55.visual_hour=12.
	sample.time55.apply_look()
	for i in 40: await physics_frame
	var results := []
	for style in 3:
		sample.bridge59.set_pair(style)
		for i in 15: await process_frame
		var result: Dictionary=await record(sample,180,false)
		result.style=style
		result.draw_calls=Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME)
		result.primitives=Performance.get_monitor(Performance.RENDER_TOTAL_PRIMITIVES_IN_FRAME)
		results.append(result)
		print("BRIDGE59_PERF ",JSON.stringify(result))
	var file := FileAccess.open("res://docs/bridge59-performance.json",FileAccess.WRITE)
	file.store_string(JSON.stringify({"frames_per_style":180,"results":results},"\t"))
	quit()
