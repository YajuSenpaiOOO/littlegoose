extends "res://scripts/world/woodland46_probe.gd"
class PerfSample:
	extends "res://scripts/world/world52.gd"
	func _hero_script() -> Script: return LivingActor
	func fire_input_held() -> bool: return false

func record(sample: Node3D,frames: int,walking: bool) -> Dictionary:
	var timings: Array[float]=[]
	var cpu: Array[float]=[]
	var previous := Time.get_ticks_usec()
	for i in frames:
		if walking:
			var target: Vector2=sample.meadow.main_route[5] if i<frames/2 else sample.meadow.main_route[4]
			sample.hero.wish=(target-Vector2(sample.hero.position.x,sample.hero.position.z)).normalized()
		await process_frame
		var now := Time.get_ticks_usec()
		timings.append(float(now-previous)/1000.)
		cpu.append(Performance.get_monitor(Performance.TIME_PROCESS)*1000.)
		previous=now
	sample.hero.wish=Vector2.ZERO
	timings.sort(); cpu.sort()
	var above33 := 0
	var above50 := 0
	for value in timings:
		if value>33.3: above33+=1
		if value>50.: above50+=1
	return {"median_ms":timings[frames/2],"p95_ms":timings[int(frames*.95)],"p99_ms":timings[int(frames*.99)],"max_ms":timings[-1],"frames_above_33ms":above33,"frames_above_50ms":above50,"cpu_median_ms":cpu[frames/2]}

func run() -> void:
	var sample: Node3D=PerfSample.new()
	root.add_child(sample)
	while not is_instance_valid(sample.sun_dust52): await physics_frame
	sample.label.get_parent().hide()
	sample._travel_region("trail")
	for i in 60: await physics_frame
	var result := {}
	for spec in [[false,false,"off"],[true,false,"dust"],[false,true,"fill"],[true,true,"both"]]:
		sample.sun_dust52.set_enabled(spec[0])
		sample.porch49.set_fill(spec[1])
		sample._teleport15(sample.meadow.main_route[4])
		for i in 10: await physics_frame
		sample.hero.controls_enabled=true
		result[spec[2]+"_first_walk"]=await record(sample,180,true)
		sample._teleport15(sample.meadow.main_route[4])
		result[spec[2]+"_repeat_walk"]=await record(sample,180,true)
		print("AIR52_PERF ",spec[2]," ",JSON.stringify(result[spec[2]+"_repeat_walk"]))
	var output := FileAccess.open("res://docs/air52-performance.json",FileAccess.WRITE)
	output.store_string(JSON.stringify(result,"\t"))
	quit()
