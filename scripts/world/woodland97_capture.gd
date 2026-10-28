extends "res://scripts/world/woodland97_probe.gd"
func run() -> void:
 root.size=Vector2i(2560,1494);DisplayServer.window_set_size(root.size)
 var sample := Sample97.new();root.add_child(sample)
 while not sample.woodland_ready97: await physics_frame
 await settle72(20)
 sample.hero.controls_enabled=false;sample.label.get_parent().hide();sample.frames66.panel.hide()
 var g: Vector2=sample.meadow.landmarks.grove
 sample.time55.preview_at(12.);sample.time55.visual_hour=12.;sample.time55.apply_look()
 await shot97(sample,g+Vector2(-1,5),"park_day")
 await shot97(sample,g+Vector2(-10,2.5),"overlook_day")
 await shot97(sample,g+Vector2(8,-2),"swing_day")
 await shot97(sample,g+Vector2(-4,13),"play_day")
 sample._teleport15(g+Vector2(-1,5));await settle72(40)
 sample.process_mode=Node.PROCESS_MODE_DISABLED
 sample.camera.global_position+=sample.camera.global_basis.z*10.
 sample.atmosphere41.focus_material.set_shader_parameter("radius_pixels",0.)
 var frame := await snapshot();frame.save_png("res://docs/captures/world_restart/woodland97_park_overview_day.png")
 print("PARK97_CAPTURE_COMPLETE");quit()
