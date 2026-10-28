extends SceneTree
## Short repeatable rendering sample, not a combat or cross-device benchmark.
class Walker extends Node:
	var scene: Node2D
	var path := PackedVector2Array()
	var index := 1
	func _physics_process(delta: float) -> void:
		var target := path[index]
		if scene.hero.position.distance_to(target)<4:
			index = mini(index+1,path.size()-1)
			target = path[index]
		scene.hero.velocity = (target-scene.hero.position).normalized()*115.0
		scene.hero.move_and_slide()
func _initialize() -> void:
	_run.call_deferred()
func _run() -> void:
	Engine.max_fps = 120
	var duration := 0.0
	for arg in OS.get_cmdline_user_args():
		if arg=="--uncapped": Engine.max_fps = 0
		if arg.begins_with("--duration="): duration = maxf(0,float(arg.trim_prefix("--duration=")))
	DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
	var scene: Node2D = load("res://scenes/world/world_restart.tscn").instantiate()
	root.add_child(scene)
	await process_frame
	scene.overview = false
	scene.hero.set_physics_process(false)
	scene.hero.position = scene.routes[0][0]
	scene.hero.reset_physics_interpolation()
	scene._apply_camera(true)
	var walker := Walker.new()
	walker.scene = scene
	walker.path = scene.routes[0]
	scene.add_child(walker)
	if duration>0:
		var warmup := Time.get_ticks_usec()
		while Time.get_ticks_usec()-warmup<1000000: await process_frame
	else:
		for i in 60: await process_frame
	var samples: Array[float] = []
	var cpu: Array[float] = []
	var previous := Time.get_ticks_usec()
	var started := previous
	while (Time.get_ticks_usec()-started)/1000000.0<duration if duration>0 else samples.size()<360:
		await process_frame
		var now := Time.get_ticks_usec()
		samples.append((now-previous)/1000.0)
		cpu.append(Performance.get_monitor(Performance.TIME_PROCESS)*1000.0)
		previous = now
	samples.sort()
	cpu.sort()
	var slow := 0
	for value in samples:
		if value>25: slow += 1
	var count := samples.size()
	var report := {"frames":count,"duration_seconds":(previous-started)/1000000.0,"fps_cap":Engine.max_fps,"vsync":false,"frame_median_ms":samples[floori((count-1)*0.5)],"frame_p95_ms":samples[floori((count-1)*0.95)],"frame_p99_ms":samples[floori((count-1)*0.99)],"frame_max_ms":samples[-1],"over_25ms":slow,"cpu_p95_ms":cpu[floori((count-1)*0.95)],"physics_interpolation":physics_interpolation,"grass_count":scene.grass_field.tufts.size(),"grass_active":scene.grass_field.active}
	var file_name := "res://docs/captures/world_restart/motion-benchmark.json"
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--report="): file_name = arg.trim_prefix("--report=")
	var file := FileAccess.open(file_name,FileAccess.WRITE)
	file.store_string(JSON.stringify(report,"\t"))
	print("MOTION_BENCHMARK ",JSON.stringify(report))
	quit()
