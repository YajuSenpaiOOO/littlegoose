extends "res://scripts/ground_lab_probe.gd"
func run() -> void:
	var s := preload("res://scripts/world/world_surface78.gd").new()
	var old := preload("res://scripts/world/world_surface77.gd").new()
	verify(s.world_bounds==old.world_bounds,"regional changes do not enlarge the world")
	verify(s.water.size()>old.water.size()*3 and s.island.size()>old.island.size()*3,"shorelines gain curved intermediate points")
	verify(not Geometry2D.triangulate_polygon(s.water).is_empty() and not Geometry2D.triangulate_polygon(s.island).is_empty(),"both curved shore polygons remain triangulatable")
	var flat := true
	for i in 24:
		var angle := TAU*i/24.
		var at: Vector2=s.landmarks.grove+Vector2(cos(angle),sin(angle))*s.FIELD_RADII76*.96
		flat=flat and absf(s.height_at(at.x,at.y,true)-2.1)<.06
	verify(flat,"40 by 30m battle clearing remains flat")
	var preserved := true
	for i in 21:
		var at: Vector2=Vector2(lerpf(s.bridge_rect.position.x-2.,s.bridge_rect.end.x+2.,i/20.),s.bridge_rect.get_center().y)
		preserved=preserved and absf(s.walk_height(at,true)-old.walk_height(at,true))<.03 and s.is_water(at)==old.is_water(at)
	verify(preserved,"bridge and its immediate landings retain heights and water classification")
	var changed := 0
	for x in [-68.,-62.,-48.,-42.,-33.]:
		if absf(s.upper_front73(x)-old.upper_front73(x))>1.: changed+=1
	verify(changed>=3,"rear forest outline has several distinct large advances and recesses")
	verify(absf(s.height_at(-64.,-84.,true)-6.25)<.05,"rear rocks retain a real broad forest top")
	var file := FileAccess.open("res://docs/landscape78-audit.json",FileAccess.WRITE)
	file.store_string(JSON.stringify({"checks":checks,"failures":failures,"water_points":s.water.size(),"island_points":s.island.size()},"\t"))
	print("LANDSCAPE78_AUDIT ",checks," failures=",failures.size());quit(0 if failures.is_empty() else 1)
