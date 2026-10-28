extends "res://scripts/world/world_map19.gd"
var terrain_texture72: ImageTexture

func _ready() -> void:
	var image := Image.create(256,192,false,Image.FORMAT_RGB8)
	for y in 192:
		for x in 256:
			var at: Vector2=surface.world_bounds.position+Vector2((x+.5)/256.,(y+.5)/192.)*surface.world_bounds.size
			var h: float=surface.height_at(at.x,at.y,true)
			var color := Color("56644b")
			if h>1.3: color=Color("889476")
			if h>3.5: color=Color("b6bda1")
			if surface.is_water(at): color=Color("355e73")
			image.set_pixel(x,y,color)
	terrain_texture72=ImageTexture.create_from_image(image)

func _draw() -> void:
	draw_style_box(_panel(),Rect2(Vector2.ZERO,size))
	var font := ThemeDB.fallback_font
	draw_string(font,Vector2(16,23),"整图地势 · 连续高地与铁路预留",HORIZONTAL_ALIGNMENT_LEFT,-1,17,Color("f2e5bd"))
	if terrain_texture72: draw_texture_rect(terrain_texture72,Rect2(18,32,374,248),false)
	for route in surface.named_routes:
		var points := PackedVector2Array()
		for p in route.points: points.append(point(p))
		draw_polyline(points,Color("e8ce9b"),2.,true)
	var rect: Rect2=surface.rail_rect72.intersection(surface.world_bounds)
	draw_rect(Rect2(point(rect.position),point(rect.end)-point(rect.position)),Color("e5d5ba"),false,1.5)
	draw_string(font,point(rect.get_center())+Vector2(-22,-7),"铁路",HORIZONTAL_ALIGNMENT_LEFT,-1,13,Color("f2e5bd"))
	for key in {"home":"小院","junction":"岔路","grove":"林地","shore":"湖岸","station":"车站","landing":"码头"}:
		var names := {"home":"小院","junction":"岔路","grove":"林地","shore":"湖岸","station":"车站","landing":"码头"}
		var p := point(surface.landmarks[key])
		draw_circle(p,3.,Color("f0dfbd"))
		draw_string(font,p+Vector2(5,-4),names[key],HORIZONTAL_ALIGNMENT_LEFT,-1,14,Color("f0dfbd"))
	draw_circle(point(Vector2(actor.position.x,actor.position.z)),4.5,Color("f6c7df"))
	draw_string(font,Vector2(18,302),"深：生活低地    中：主台地    浅：后林台",HORIZONTAL_ALIGNMENT_LEFT,-1,14,Color("e1ddc8"))
