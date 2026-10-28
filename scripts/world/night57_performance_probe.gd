extends "res://scripts/world/air52_performance_probe.gd"
class NightPerfSample:
	extends "res://scripts/world/world57.gd"
	func _hero_script() -> Script: return LivingActor
	func fire_input_held() -> bool: return false

func run() -> void:
	var sample: Node3D=NightPerfSample.new()
	root.add_child(sample)
	while not is_instance_valid(sample.time55) or not sample.time55.is_node_ready(): await physics_frame
	sample.label.get_parent().hide()
	sample._travel_region("trail")
	sample.hero.controls_enabled=false
	var time: Node=sample.time55
	var cycle: RefCounted=time.clock55
	for i in 60: await physics_frame
	var results := []
	# Interleave fixed/moving samples to reduce warm-up and drift bias.
	for mode in ["fixed","moving","moving","fixed","night_off","night_on","night_on","night_off"]:
		time.focused=true
		time.freeze_sun57=false
		cycle.hour=15. if mode in ["fixed","moving"] else 22.
		cycle.speed=1.
		cycle.paused=false
		time.preview=mode.begins_with("night")
		time.visual_hour=cycle.hour
		var enabled: bool=mode=="night_on"
		time.accents57.fireflies_enabled=enabled
		time.accents57.stage_enabled=enabled
		time.haze_enabled57=enabled
		time.apply_look()
		time.freeze_sun57=mode=="fixed"
		for i in 20: await process_frame
		var updates_before: int=time.pose_updates57
		var measure: Dictionary=await record(sample,240,false)
		measure.mode=mode
		measure.pose_updates=time.pose_updates57-updates_before
		measure.draw_calls=Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME)
		results.append(measure)
		print("NIGHT57_PERF ",JSON.stringify(measure))
	var file := FileAccess.open("res://docs/night57-performance.json",FileAccess.WRITE)
	file.store_string(JSON.stringify({"frames_per_sample":240,"renderer":RenderingServer.get_current_rendering_method(),"results":results},"\t"))
	quit()
