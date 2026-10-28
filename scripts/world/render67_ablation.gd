extends "res://scripts/world/air52_performance_probe.gd"
class Sample:
	extends "res://scripts/world/world66.gd"
	func _hero_script() -> Script: return LivingActor
	func fire_input_held() -> bool: return false

func run() -> void:
	var sample := Sample.new()
	root.add_child(sample)
	while not is_instance_valid(sample.frames66): await physics_frame
	sample.label.get_parent().hide()
	sample.hero.controls_enabled=false
	sample.time55.preview_at(12.); sample.time55.visual_hour=12.; sample.time55.apply_look()
	var initial_sync := DisplayServer.window_get_vsync_mode()
	var result := {"renderer":RenderingServer.get_current_rendering_method(),"initial_vsync":initial_sync,"max_fps":Engine.max_fps,"refresh_hz":DisplayServer.screen_get_refresh_rate(),"size":DisplayServer.window_get_size(),"root":{},"lake":{}}
	for location in ["root","lake"]:
		if location=="root": sample.go_roots64()
		else: sample.go_bridge59()
		for spec in ["native_full","uncapped_full","old_fade","no_blur","no_post","water_still","small_window","full_repeat"]:
			DisplayServer.window_set_vsync_mode(initial_sync if spec=="native_full" else DisplayServer.VSYNC_DISABLED)
			sample.canopy66.set_local(spec!="old_fade")
			sample.atmosphere41.focus_card.visible=spec!="no_post"
			sample.atmosphere41.focus_material.set_shader_parameter("radius_pixels",0. if spec=="no_blur" else 6.2)
			sample.bridge59.set_motion(spec!="water_still"); sample.bridge59.set_sparkles(spec!="water_still")
			DisplayServer.window_set_size(Vector2i(960,600) if spec=="small_window" else Vector2i(1440,900))
			for i in 20: await physics_frame
			result[location][spec]=await record(sample,180,false)
			result[location][spec].draw_calls=Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME)
			print("RENDER67 ",location," ",spec," ",JSON.stringify(result[location][spec]))
	var file := FileAccess.open("res://docs/render67-ablation.json",FileAccess.WRITE)
	file.store_string(JSON.stringify(result,"\t"))
	quit()
