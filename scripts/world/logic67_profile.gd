extends "res://scripts/world/air52_performance_probe.gd"
class Sample:
	extends "res://scripts/world/world67.gd"
	var process_us := 0
	var physics_us := 0
	func _hero_script() -> Script: return LivingActor
	func fire_input_held() -> bool: return false
	func _process(delta: float) -> void:
		var start := Time.get_ticks_usec()
		super._process(delta)
		process_us+=Time.get_ticks_usec()-start
	func _physics_process(delta: float) -> void:
		var start := Time.get_ticks_usec()
		super._physics_process(delta)
		physics_us+=Time.get_ticks_usec()-start

func collect(node: Node,found: Array[Node]) -> void:
	for child in node.get_children():
		if child.is_processing(): found.append(child)
		collect(child,found)

func run() -> void:
	var sample := Sample.new()
	root.add_child(sample)
	while not is_instance_valid(sample.frames66): await physics_frame
	DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
	sample.hero.controls_enabled=false
	sample.time55.preview_at(12.); sample.time55.visual_hour=12.; sample.time55.apply_look()
	var nodes: Array[Node]=[]
	collect(sample,nodes)
	var results := {"max_fps":Engine.max_fps,"native_shadows":sample.sun.shadow_enabled,"size":str(DisplayServer.window_get_size()),"stages":{}}
	for stage in ["full","no_time","no_wind_leaves","no_dust","no_world_process","no_child_process","full_repeat"]:
		for node in nodes:
			if is_instance_valid(node): node.set_process(true)
		sample.set_process(stage!="no_world_process")
		if stage=="no_time": sample.time55.set_process(false)
		if stage=="no_wind_leaves": sample.woodland_life.set_process(false)
		if stage=="no_dust": sample.sun_dust52.set_process(false)
		if stage=="no_child_process":
			for node in nodes:
				if is_instance_valid(node): node.set_process(false)
		for i in 25: await physics_frame
		sample.process_us=0; sample.physics_us=0
		results.stages[stage]=await record(sample,240,false)
		results.stages[stage].world_process_ms=sample.process_us/1000./240.
		results.stages[stage].world_physics_total_ms=sample.physics_us/1000.
		print("LOGIC67 ",stage," ",JSON.stringify(results.stages[stage]))
	var file := FileAccess.open("res://docs/logic67-profile.json",FileAccess.WRITE)
	file.store_string(JSON.stringify(results,"\t"))
	quit()
