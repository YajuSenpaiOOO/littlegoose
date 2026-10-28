extends "res://scripts/world/render67_ablation.gd"

func run() -> void:
	var sample := Sample.new()
	root.add_child(sample)
	while not is_instance_valid(sample.frames66): await physics_frame
	DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
	sample.hero.controls_enabled=false
	sample.time55.preview_at(12.); sample.time55.visual_hour=12.; sample.time55.apply_look()
	var results := {}
	for location in ["root","lake"]:
		if location=="root": sample.go_roots64()
		else: sample.go_bridge59()
		results[location]={}
		for spec in ["full1440","full2560","no_blur2560","no_shadow1440","frozen_logic1440","full_repeat1440"]:
			sample.process_mode=Node.PROCESS_MODE_INHERIT
			sample.sun.shadow_enabled=spec!="no_shadow1440"
			sample.atmosphere41.focus_material.set_shader_parameter("radius_pixels",0. if spec=="no_blur2560" else 6.2)
			DisplayServer.window_set_size(Vector2i(2560,1600) if "2560" in spec else Vector2i(1440,900))
			for i in 25: await physics_frame
			if spec=="frozen_logic1440": sample.process_mode=Node.PROCESS_MODE_DISABLED
			results[location][spec]=await record(sample,180,false)
			results[location][spec].draw_calls=Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME)
			print("CEILING67 ",location," ",spec," ",JSON.stringify(results[location][spec]))
			sample.process_mode=Node.PROCESS_MODE_INHERIT
	var file := FileAccess.open("res://docs/render67-ceiling.json",FileAccess.WRITE)
	file.store_string(JSON.stringify(results,"\t"))
	quit()
