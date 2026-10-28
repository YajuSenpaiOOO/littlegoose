extends SceneTree
func _initialize() -> void:
	var profiles := {}
	for id in ["oak","young","cottage"]:
		var image := Image.load_from_file("res://assets/forest13/%s.png"%id)
		var low := Vector2i(image.get_width(),image.get_height())
		var high := Vector2i.ZERO
		for y in image.get_height():
			for x in image.get_width():
				if image.get_pixel(x,y).a<.5: continue
				low = low.min(Vector2i(x,y))
				high = high.max(Vector2i(x+1,y+1))
		var root_x := 0.
		var total := 0.
		for y in range(high.y-12,high.y):
			for x in range(low.x,high.x):
				if image.get_pixel(x,y).a<.5: continue
				root_x += x
				total += 1.
		var foot_x := root_x/maxf(total,1.)
		if id=="cottage": foot_x = float(low.x+high.x)/2.
		profiles[id] = {"bounds":[low.x,low.y,high.x-low.x,high.y-low.y],"foot":[foot_x,high.y],"height":high.y-low.y}
		print(id," ",profiles[id]," alpha_left_mid=",image.get_pixel(10,image.get_height()/2).a)
	var file := FileAccess.open("res://assets/forest13/profiles.json",FileAccess.WRITE)
	file.store_string(JSON.stringify(profiles,"\t"))
	quit()
