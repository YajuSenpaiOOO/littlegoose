extends SceneTree
func _initialize() -> void:
	var profiles: Array = []
	for id in ["a","b","c"]:
		var image: Image = load("res://assets/ground_lab10/%s_grass.png"%id).get_image()
		var width := image.get_width()/4
		var cells: Array = []
		for i in 4:
			var low := Vector2i(width,image.get_height())
			var high := Vector2i.ZERO
			for y in image.get_height():
				for x in width:
					if image.get_pixel(x+i*width,y).a>=.5:
						low = low.min(Vector2i(x,y))
						high = high.max(Vector2i(x+1,y+1))
			var bounds := Rect2i(low,high-low).grow(3).intersection(Rect2i(0,0,width,image.get_height()))
			cells.append([bounds.position.x,bounds.position.y,bounds.size.x,bounds.size.y])
		profiles.append({"id":id,"cell_size":[width,image.get_height()],"cells":cells})
	FileAccess.open("res://assets/ground_lab10/profiles.json",FileAccess.WRITE).store_string(JSON.stringify(profiles,"\t"))
	print("GROUND_LAB_PROFILES ",profiles.size()," styles, 4 separate texture layers each")
	quit()
