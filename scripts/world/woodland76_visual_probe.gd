extends "res://scripts/world/woodland76_probe.gd"
func run() -> void:
	var sample := ForestSample.new();root.add_child(sample)
	while not is_instance_valid(sample.wall76): await physics_frame
	await settle72()
	sample.label.get_parent().hide();sample.frames66.panel.hide()
	await shot76(sample,Vector2(-26.,-32.3),"entry_sample")
	sample.time55.preview_at(22.);sample.time55.visual_hour=22.;sample.time55.apply_look();await settle72(45)
	verify(absf(sample.time55.visual_hour-22.)<.01,"sample night capture is locked to 22:00 rather than easing back to noon")
	var night := await snapshot();night.save_png("res://docs/captures/world_restart/woodland76_sample_night.png")
	verify(sample.navigation.outside_cells76>0,"live world uses the navigation boundary mask")
	print("WOODLAND76_VISUAL checks=",checks," failures=",failures.size())
	quit(0 if failures.is_empty() else 1)
