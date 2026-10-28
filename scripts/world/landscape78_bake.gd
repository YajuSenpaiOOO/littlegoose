extends SceneTree
func _initialize() -> void:
	var s := preload("res://scripts/world/world_surface78.gd").new()
	var bounds: Rect2=s.world_bounds
	var image := Image.create(512,384,false,Image.FORMAT_RGB8)
	for y in 384:
		for x in 512:
			var at: Vector2=bounds.position+Vector2((x+.5)/512.,(y+.5)/384.)*bounds.size
			var d: float=clampf(s.shore_distance78(at)/8.,0.,1.)
			image.set_pixel(x,y,Color(d,d,d))
	DirAccess.make_dir_recursive_absolute("res://assets/landscape78")
	image.save_png("res://assets/landscape78/shore_distance78.png")
	var file := FileAccess.open("res://assets/landscape78/shore_distance78.json",FileAccess.WRITE)
	file.store_string(JSON.stringify({"bounds":[bounds.position.x,bounds.position.y,bounds.size.x,bounds.size.y],"distance_range":8,"size":[512,384],"source":"world_surface78 water/island outlines"},"\t"))
	print("SHORE78_DISTANCE_BAKED");quit()
