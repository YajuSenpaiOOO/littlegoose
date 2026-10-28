extends "res://scripts/world/terrace74_probe.gd"

func run() -> void:
	var sample := WideSample.new();root.add_child(sample)
	while not is_instance_valid(sample.rail72): await physics_frame
	await settle72()
	sample.label.get_parent().hide();sample.frames66.panel.hide()
	var station: Vector2=sample.meadow.landmarks.station
	await shot73(sample,station+Vector2(1,15),"station_front")
	await shot73(sample,station+Vector2(18,9),"brick_side")
	await shot73(sample,Vector2(station.x,sample.meadow.rail_z73+2.5),"platform_rail")
	sample.set_review72(true);await settle72()
	var overview := await snapshot();overview.save_png("res://docs/captures/world_restart/terrace74_overview.png")
	sample.set_review72(false);sample.label.get_parent().show();sample.map_panel.show();await settle72()
	verify(sample.map_panel.get_script().resource_path.ends_with("world_map74.gd"),"current terrain map distinguishes the station shelf")
	var map_shot := await snapshot();map_shot.save_png("res://docs/captures/world_restart/terrace74_map.png")
	print("TERRACE74_VISUAL_READY checks=",checks," failures=",failures.size())
	quit(0 if failures.is_empty() else 1)
