extends "res://scripts/world/air52_performance_probe.gd"
class SpotPerfSample:
	extends "res://scripts/world/world58.gd"
	func _hero_script() -> Script: return LivingActor
	func fire_input_held() -> bool: return false

func run() -> void:
	var sample: Node3D=SpotPerfSample.new()
	root.add_child(sample)
	while not is_instance_valid(sample.time55) or not sample.time55.is_node_ready(): await physics_frame
	sample.label.get_parent().hide()
	sample._travel_region("trail")
	sample.hero.controls_enabled=false
	var time: Node=sample.time55
	time.preview_at(22.)
	time.visual_hour=22.
	for i in 45: await physics_frame
	var results := []
	for rig in [0,1,2,0]:
		time.set_rig58(rig)
		for i in 20: await process_frame
		var result: Dictionary=await record(sample,240,false)
		result.rig=rig
		result.draw_calls=Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME)
		results.append(result)
		print("SPOT58_PERF ",JSON.stringify(result))
	var file := FileAccess.open("res://docs/spot58-performance.json",FileAccess.WRITE)
	file.store_string(JSON.stringify({"frames_per_rig":240,"renderer":RenderingServer.get_current_rendering_method(),"results":results},"\t"))
	quit()
