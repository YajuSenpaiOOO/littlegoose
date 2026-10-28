extends Control
var surface: RefCounted
var actor: Node3D
func point(at: Vector2) -> Vector2:
	return Vector2(18,32)+(at-surface.world_bounds.position)/surface.world_bounds.size*Vector2(374,248)
func _draw() -> void:
	draw_style_box(_panel(),Rect2(Vector2.ZERO,size))
	var font := ThemeDB.fallback_font
	draw_string(font,Vector2(16,23),"连续地图 · 位置与连接",HORIZONTAL_ALIGNMENT_LEFT,-1,18,Color("f2e5bd"))
	var lake := PackedVector2Array()
	for p in surface.water: lake.append(point(p))
	draw_colored_polygon(lake,Color("355e73"))
	var island := PackedVector2Array()
	for p in surface.island: island.append(point(p))
	draw_colored_polygon(island,Color("405c3d"))
	for route in surface.named_routes:
		var points := PackedVector2Array()
		for p in route.points: points.append(point(p))
		draw_polyline(points,Color("ebc879") if route.name=="home_to_junction" else Color("9baf83"),2.5,true)
	var names := {"home":"小院","junction":"岔路","grove":"林地","shore":"湖岸","station":"车站预留","landing":"码头预留"}
	for key in names:
		var p := point(surface.landmarks[key])
		draw_circle(p,3.5,Color("e9dbad"))
		draw_string(font,p+Vector2(6,-4),names[key],HORIZONTAL_ALIGNMENT_LEFT,-1,15,Color("e9dbad"))
	draw_circle(point(Vector2(actor.position.x,actor.position.z)),5.,Color("f6c7df"))
func _panel() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(.065,.11,.095,.94)
	style.corner_radius_top_left = 8
	style.corner_radius_bottom_right = 8
	return style
