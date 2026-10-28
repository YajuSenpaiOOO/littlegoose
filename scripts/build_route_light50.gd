extends SceneTree
func _initialize() -> void:
	var palette_path := "res://assets/lighting50/warm_woodland.tres"
	var output_prefix := "res://assets/lighting50/home_trail_field"
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--palette="): palette_path=arg.trim_prefix("--palette=")
		if arg.begins_with("--output="): output_prefix=arg.trim_prefix("--output=")
	var palette: Resource=load(palette_path)
	if palette==null:
		push_error("Cannot load light palette: "+palette_path)
		quit(1)
		return
	var meadow=preload("res://scripts/world/world_surface20.gd").new()
	var baker=preload("res://scripts/art/route_light_baker50.gd").new()
	for route in meadow.named_routes:
		if route.name==palette.route_name: baker.prepare(route.points,palette)
	if baker.points.size()<2:
		push_error("Lighting profile route does not exist: "+palette.route_name)
		quit(1)
		return
	DirAccess.make_dir_recursive_absolute(output_prefix.get_base_dir())
	var image: Image=baker.bake()
	var error: Error=image.save_png(output_prefix+".png")
	if error!=OK:
		push_error("Cannot write light atlas: "+output_prefix)
		quit(1)
		return
	var lights: Array=[]
	for opening in baker.openings:
		lights.append({"at":[opening.at.x,opening.at.y],"forward":[opening.forward.x,opening.forward.y],"radius":[opening.radius.x,opening.radius.y],"distance":opening.distance})
	var out := FileAccess.open(output_prefix+".json",FileAccess.WRITE)
	out.store_string(JSON.stringify({"bounds":[baker.bounds.position.x,baker.bounds.position.y,baker.bounds.size.x,baker.bounds.size.y],"openings":lights,"resolution":palette.map_resolution},"\t"))
	print("LIGHTFIELD50_BAKED ",baker.openings.size()," openings ",baker.bounds)
	quit()
