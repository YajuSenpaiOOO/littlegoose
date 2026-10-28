extends SceneTree
func _initialize() -> void: run.call_deferred()
func run() -> void:
	var sample: Node3D=load("res://scenes/world/world43.tscn").instantiate()
	root.add_child(sample)
	while not is_instance_valid(sample.atmosphere41): await physics_frame
	while not sample.atmosphere41.grass_ready: await physics_frame
	sample.hero.controls_enabled=false
	sample._travel_region("home")
	var art: Node3D=sample.atmosphere41
	var report: Array[Dictionary]=[]
	for mode in ["original","plants_no_focus","focus_strong","focus_heavy"]:
		art.set_enabled(mode!="original")
		art._set_focus_level(3 if mode=="focus_heavy" else (2 if mode=="focus_strong" else 0))
		for i in 40: await process_frame
		var start := Time.get_ticks_usec()
		var samples: Array[float]=[]
		for i in 120:
			var last := Time.get_ticks_usec()
			await process_frame
			samples.append((Time.get_ticks_usec()-last)/1000.)
		samples.sort()
		var entry := {"mode":mode,"fps":120000000./float(Time.get_ticks_usec()-start),"median_ms":samples[60],"p95_ms":samples[114],"draws":Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME)}
		report.append(entry)
		print("VEGETATION43_PERF ",JSON.stringify(entry))
	var file := FileAccess.open("res://docs/vegetation43-performance.json",FileAccess.WRITE)
	file.store_string(JSON.stringify({"resolution":[root.size.x,root.size.y],"samples":report},"\t"))
	quit()
