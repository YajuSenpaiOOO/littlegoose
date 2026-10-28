extends "res://scripts/ground_lab_probe.gd"
func area79(polygon: PackedVector2Array) -> float:
	var area := 0.
	for i in polygon.size(): area+=polygon[i].cross(polygon[(i+1)%polygon.size()])
	return absf(area)*.5
func run() -> void:
	var s := preload("res://scripts/world/world_surface79.gd").new()
	var old := preload("res://scripts/world/world_surface78.gd").new()
	verify(s.world_bounds.end.x>old.world_bounds.end.x+57.9 and s.world_bounds.position==old.world_bounds.position,"only east expands for the enclosing lake and far forest")
	verify(area79(s.island)>area79(old.island)*1.4,"island gains at least forty percent real land area")
	verify(not Geometry2D.triangulate_polygon(s.water).is_empty() and not Geometry2D.triangulate_polygon(s.island).is_empty(),"expanded lake and island polygons remain triangulatable")
	var surrounded := true;var east := -INF
	for p in s.island: surrounded=surrounded and Geometry2D.is_point_in_polygon(p,s.water);east=maxf(east,p.x)
	verify(surrounded and s.world_bounds.end.x-east>35.,"island is fully inside the lake with over 35m to east world boundary")
	var water_area := 0.;var holes_clear := true
	for piece in s.lake_pieces79():
		water_area+=area79(piece)
		var triangles := Geometry2D.triangulate_polygon(piece)
		for i in range(0,triangles.size(),3):
			var center := (piece[triangles[i]]+piece[triangles[i+1]]+piece[triangles[i+2]])/3.
			holes_clear=holes_clear and s.is_water(center)
	print("WATER79_SPLIT area=",water_area," expected=",area79(s.water)-area79(s.island)," clear=",holes_clear," pieces=",s.lake_pieces79().size())
	verify(absf(water_area-(area79(s.water)-area79(s.island)))<.05 and holes_clear,"split water triangulation excludes the fully enclosed island hole")
	var bridge_ok := true
	for i in 21:
		var at := Vector2(lerpf(s.bridge_rect.position.x-1.,s.bridge_rect.end.x+1.,i/20.),s.bridge_rect.get_center().y)
		bridge_ok=bridge_ok and absf(s.walk_height(at,true)-old.walk_height(at,true))<.03 and s.is_water(at)==old.is_water(at)
	verify(bridge_ok,"bridge height and both immediate landings are preserved")
	verify(s.route_distance(s.landmarks.home+Vector2(0.,.05))<.05,"dirt path starts at the actual cottage step foot")
	verify(s.ground_patches79.size()==8 and s.ground_cover79(Vector2(-4.5,-2.8)).y>.99 and s.ground_cover79(Vector2(-66.,-53.)).x==1. and s.ground_cover79(Vector2(-11.,.9)).x==2.,"yard earth woodland humus and flower ground have explicit reusable regions")
	var flat := true
	for i in 24:
		var a := TAU*i/24.;var p: Vector2=s.landmarks.grove+Vector2(cos(a),sin(a))*s.FIELD_RADII76*.96
		flat=flat and absf(s.height_at(p.x,p.y,true)-2.1)<.06
	verify(flat,"existing forest clearing remains unchanged and flat")
	verify(is_equal_approx(s.rail_alignment73.y,s.world_bounds.end.x),"rail ends exactly at the new east world boundary")
	var report := {"checks":checks,"failures":failures,"island_area_old":area79(old.island),"island_area_new":area79(s.island),"island_east":east,"world_east":s.world_bounds.end.x,"water_points":s.water.size(),"island_points":s.island.size()}
	var file := FileAccess.open("res://docs/lake79-audit.json",FileAccess.WRITE);file.store_string(JSON.stringify(report,"\t"))
	print("LAKE79_AUDIT ",JSON.stringify(report));quit(0 if failures.is_empty() else 1)
