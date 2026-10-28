extends "res://scripts/build_forest14_profiles.gd"
func gaps(image: Image) -> Array[int]:
	var result: Array[int] = [0]
	for boundary in [1,2]:
		var center := float(image.get_width())*float(boundary)/3.
		var span := int(image.get_width()*.10)
		var longest := 0
		var run := 0
		var split := int(center)
		for x in range(int(center)-span,int(center)+span):
			var clear := true
			for y in image.get_height():
				if image.get_pixel(x,y).a>=.5: clear = false; break
			run = run+1 if clear else 0
			if run>longest:
				longest = run
				split = x-run/2
		result.append(split)
	result.append(image.get_width())
	return result

func _initialize() -> void:
	var all := {}
	for id in ["cottage_a","cottage_b"]:
		var file := "res://assets/yard15/%s.png"%id
		var image := Image.load_from_file(file)
		var data := profile(image)
		# Anchor the FRONT doorstep, not the lowest pixel of a receding side wall.
		var front_x := image.get_width()*(.46 if id=="cottage_a" else .50)
		var bottoms: Array[int] = []
		for x in range(int(front_x)-25,int(front_x)+26):
			for y in range(image.get_height()-1,-1,-1):
				if image.get_pixel(x,y).a>=.5: bottoms.append(y+1); break
		bottoms.sort()
		data.foot = [front_x,bottoms[bottoms.size()/2]]
		data.file = file
		all[id] = data
	for sheet in ["trees","props"]:
		var file := "res://assets/yard15/%s.png"%sheet
		var image := Image.load_from_file(file)
		var edges := gaps(image)
		for i in 3:
			var rect := Rect2i(edges[i],0,edges[i+1]-edges[i],image.get_height())
			var cell := image.get_region(rect)
			var padded := Image.create(cell.get_width()+8,cell.get_height()+8,false,Image.FORMAT_RGBA8)
			padded.fill(Color.TRANSPARENT)
			padded.blit_rect(cell,Rect2i(Vector2i.ZERO,cell.get_size()),Vector2i(4,4))
			var data := profile(padded)
			if sheet=="props": data.foot[0] = float(data.bounds[0])+float(data.bounds[2])/2.
			data.file = file
			data.cell = [rect.position.x,rect.position.y,rect.size.x,rect.size.y]
			data.padding = 4
			var id: String = "tree_%d"%i if sheet=="trees" else ["wood","bench","wall"][i]
			all[id] = data
	var output := FileAccess.open("res://assets/yard15/profiles.json",FileAccess.WRITE)
	output.store_string(JSON.stringify(all,"\t"))
	print("YARD15_PROFILES ",JSON.stringify(all))
	quit()
