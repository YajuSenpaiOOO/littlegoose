extends "res://scripts/ground_lab_probe.gd"
func run() -> void:
	var surface := preload("res://scripts/world/world_surface77.gd").new()
	var bypass: Dictionary=surface.named_road77("woodland_return72")
	var landing: Dictionary=surface.named_road77("home_to_landing")
	verify(bypass.points[0].distance_to(surface.closest_on_road77(bypass.points[0],"junction_to_grove"))<.001,"woodland bypass starts on the main woodland route")
	verify(bypass.points[-1].distance_to(surface.closest_on_road77(bypass.points[-1],"junction_ring"))<.001,"woodland bypass returns to the actual hub ring")
	verify(landing.points[0].distance_to(surface.closest_on_road77(landing.points[0],"home_to_junction"))<.001,"landing branch starts on the residential main route")
	verify(surface.road_finish77(surface.landmarks.grove)<.001 and surface.road_finish77(surface.landmarks.shore)<.001,"open-ground destination caps fade to grass")
	var highest := 0
	for iz in ceili(surface.world_bounds.grow(6.).size.y/16.):
		for ix in ceili(surface.world_bounds.grow(6.).size.x/16.):
			var rect := Rect2(surface.world_bounds.grow(6.).position+Vector2(ix,iz)*16.,Vector2(16,16))
			highest=maxi(highest,surface.chunk_segments(rect).size())
	verify(highest<=64,"connected paths remain within the per-chunk shader segment budget")
	var file := FileAccess.open("res://docs/paths77-audit.json",FileAccess.WRITE)
	file.store_string(JSON.stringify({"checks":checks,"failures":failures,"max_segments_per_chunk":highest,"bypass_start":[bypass.points[0].x,bypass.points[0].y],"bypass_end":[bypass.points[-1].x,bypass.points[-1].y],"landing_start":[landing.points[0].x,landing.points[0].y]},"\t"))
	print("PATHS77 checks=",checks," failures=",failures.size()," chunk_segments=",highest)
	quit(0 if failures.is_empty() else 1)
