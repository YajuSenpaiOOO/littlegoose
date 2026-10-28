extends SceneTree
func _initialize() -> void:
	var s := preload("res://scripts/world/world_surface79.gd").new()
	var bounds: Rect2=s.world_bounds
	var image := Image.create(768,384,false,Image.FORMAT_RGB8)
	for y in 384:
		for x in 768:
			var at: Vector2=bounds.position+Vector2((x+.5)/768.,(y+.5)/384.)*bounds.size
			var d: float=clampf(s.shore_distance78(at)/8.,0.,1.)
			image.set_pixel(x,y,Color(d,d,d))
	DirAccess.make_dir_recursive_absolute("res://assets/landscape79")
	image.save_png("res://assets/landscape79/shore_distance79.png")
	var data := {"bounds":[bounds.position.x,bounds.position.y,bounds.size.x,bounds.size.y],"distance_range":8,"size":[768,384],"water":Array(s.water),"island":Array(s.island)}
	var file := FileAccess.open("res://assets/landscape79/shore_distance79.json",FileAccess.WRITE);file.store_string(JSON.stringify(data,"\t"))
	print("LAKE79_DISTANCE_BAKED island_area=",polygon_area79(s.island));quit()

func polygon_area79(points: PackedVector2Array) -> float:
	var area := 0.
	for i in points.size(): area+=points[i].cross(points[(i+1)%points.size()])
	return absf(area)*.5
