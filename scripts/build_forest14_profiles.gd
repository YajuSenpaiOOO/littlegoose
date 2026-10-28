extends SceneTree
func profile(image: Image,cutoff: float=.5) -> Dictionary:
	var low := image.get_size()
	var high := Vector2i.ZERO
	for y in image.get_height():
		for x in image.get_width():
			if image.get_pixel(x,y).a<cutoff: continue
			low = low.min(Vector2i(x,y))
			high = high.max(Vector2i(x+1,y+1))
	var root_x := 0.
	var total := 0.
	for y in range(maxi(low.y,high.y-16),high.y):
		for x in range(low.x,high.x):
			if image.get_pixel(x,y).a<cutoff: continue
			root_x += x
			total += 1.
	return {"bounds":[low.x,low.y,high.x-low.x,high.y-low.y],"foot":[root_x/maxf(total,1.),high.y],"height":high.y-low.y,"cutoff":cutoff}

func _initialize() -> void:
	var packs := {}
	for id in ["a","b","c"]:
		var pair := Image.load_from_file("res://assets/forest14/%s_trees.png"%id)
		var pack := {}
		# Generated atlas spacing can differ from the requested equal halves.
		# Split at the middle of its clearest central alpha gap, without cutting a crown.
		var best := pair.get_height()+1
		var columns: Array[int] = []
		var begin := int(pair.get_width()*.35)
		var end := int(pair.get_width()*.65)
		var cutoff := .5
		for threshold in [.5,.6,.7,.8,.9,.95]:
			cutoff = threshold
			columns.clear()
			best = pair.get_height()+1
			for x in range(begin,end):
				var count := 0
				for y in pair.get_height():
					if pair.get_pixel(x,y).a>=threshold: count += 1
				columns.append(count)
				best = mini(best,count)
			if best==0: break
		var split := pair.get_width()/2
		var longest := 0
		var run := 0
		for i in columns.size():
			run = run+1 if columns[i]==best else 0
			if run>longest:
				longest = run
				split = begin+i-run/2
		if best!=0:
			printerr("tree pair has no usable separating alpha gap: ",id)
			quit(1)
			return
		for index in 2:
			var region := Rect2i(0,0,split,pair.get_height()) if index==0 else Rect2i(split,0,pair.get_width()-split,pair.get_height())
			var cell := pair.get_region(region)
			var padded := Image.create(cell.get_width()+8,cell.get_height()+8,false,Image.FORMAT_RGBA8)
			padded.fill(Color.TRANSPARENT)
			padded.blit_rect(cell,Rect2i(Vector2i.ZERO,cell.get_size()),Vector2i(4,4))
			var data := profile(padded,cutoff)
			data.cell = [region.position.x,region.position.y,region.size.x,region.size.y]
			data.padding = 4
			pack["oak" if index==0 else "young"] = data
		var cottage := Image.load_from_file("res://assets/forest14/%s_cottage.png"%id)
		pack.cottage = profile(cottage)
		pack.cottage.foot[0] = float(pack.cottage.bounds[0])+float(pack.cottage.bounds[2])/2.
		packs[id] = pack
		print(id," ",JSON.stringify(pack))
	var file := FileAccess.open("res://assets/forest14/profiles.json",FileAccess.WRITE)
	file.store_string(JSON.stringify(packs,"\t"))
	quit()
