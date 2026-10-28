extends SceneTree
## Read alpha bounds only; never modify generated image pixels.
func opaque_rect(image: Image,region: Rect2i) -> Rect2i:
	var low := region.end
	var high := region.position
	for y in range(region.position.y,region.end.y):
		for x in range(region.position.x,region.end.x):
			if image.get_pixel(x,y).a>=.5:
				low = low.min(Vector2i(x,y))
				high = high.max(Vector2i(x+1,y+1))
	return Rect2i(low,high-low)
func _initialize() -> void:
	var house: Image = load("res://assets/perspective09/cottage.png").get_image()
	var bounds := opaque_rect(house,Rect2i(Vector2i.ZERO,house.get_size()))
	var profile := {"texture":"res://assets/perspective09/cottage.png","foot":[bounds.position.x+bounds.size.x*.40,bounds.end.y+2],"visible_height":bounds.size.y,"visible_width":bounds.size.x,"bounds":[bounds.position.x,bounds.position.y,bounds.size.x,bounds.size.y],"view":"25 degree perspective candidate; baked right side, not a UV atlas"}
	FileAccess.open("res://assets/perspective09/cottage_profile.json",FileAccess.WRITE).store_string(JSON.stringify(profile,"\t"))
	var grass: Image = load("res://assets/perspective09/grass_sheet.png").get_image()
	var cells: Array = []
	for i in 8:
		var region := Rect2i(i%4*grass.get_width()/4,i/4*grass.get_height()/2,grass.get_width()/4,grass.get_height()/2)
		var visible := opaque_rect(grass,region)
		var padded := visible.grow(2).intersection(region)
		cells.append({"region":[padded.position.x,padded.position.y,padded.size.x,padded.size.y],"aspect":float(visible.size.x)/visible.size.y,"short":i<4})
	FileAccess.open("res://assets/perspective09/grass_profile.json",FileAccess.WRITE).store_string(JSON.stringify({"texture":"res://assets/perspective09/grass_sheet.png","size":[grass.get_width(),grass.get_height()],"cells":cells},"\t"))
	print("ART09_PROFILES house=",house.get_size()," bounds=",bounds," grass=",grass.get_size()," cells=",cells.size())
	quit()
