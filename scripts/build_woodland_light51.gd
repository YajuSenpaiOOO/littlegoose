extends SceneTree
func _initialize() -> void: run.call_deferred()
func run() -> void:
	# Follow the active project scene so later placement changes are included.
	var scene_path: String=ProjectSettings.get_setting("application/run/main_scene","res://scenes/world/world50.tscn")
	if not FileAccess.file_exists("res://assets/lighting51/woodland_openings.png"): scene_path="res://scenes/world/world50.tscn"
	var sample: Node3D=load(scene_path).instantiate()
	root.add_child(sample)
	while not is_instance_valid(sample.porch49): await physics_frame
	sample.hero.controls_enabled=false
	var config: Dictionary=JSON.parse_string(FileAccess.get_file_as_string("res://assets/lighting51/regions.json"))
	var baker=preload("res://scripts/art/woodland_light_baker51.gd").new()
	baker.prepare(sample.trees,sample.meadow,config)
	var images: Array[Image]=baker.bake()
	for i in 2:
		var suffix := "density" if i==0 else "openings"
		var error: Error=images[i].save_png("res://assets/lighting51/woodland_"+suffix+".png")
		if error!=OK:
			push_error("Cannot write woodland light atlas")
			quit(1)
			return
	var lights: Array=[]
	for opening in baker.openings:
		lights.append({"at":[opening.at.x,opening.at.y],"radius":[opening.radius.x,opening.radius.y],"region":opening.region,"preset":opening.preset,"density":baker.density_at(opening.at)})
	var metadata := {"bounds":[baker.bounds.position.x,baker.bounds.position.y,baker.bounds.size.x,baker.bounds.size.y],"tree_count":sample.trees.size(),"trees":baker.source_trees,"regions":config.regions,"openings":lights,"resolution":config.resolution}
	var out := FileAccess.open("res://assets/lighting51/woodland_openings.json",FileAccess.WRITE)
	out.store_string(JSON.stringify(metadata,"\t"))
	print("WOODLAND51_BAKED trees=",sample.trees.size()," regions=",baker.regions.size()," openings=",lights.size())
	quit()
