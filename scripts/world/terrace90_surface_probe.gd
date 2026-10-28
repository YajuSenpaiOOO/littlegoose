extends SceneTree
func _initialize() -> void:
	var surface := preload("res://scripts/world/world_surface90.gd").new()
	var baseline := preload("res://scripts/world/world_surface85.gd").new()
	var g: Vector2=surface.landmarks.grove
	var max_field := 0.;var max_change := 0.;var max_road := 0.
	for x in range(-20,21):
		for z in range(-15,16):
			var at := g+Vector2(x,z)
			if (Vector2(x,z)/Vector2(20.,15.)).length()<=1.:
				max_field=maxf(max_field,absf(surface.height_at(at.x,at.y,true)-2.1))
	for x in range(-78,-28):
		for z in range(-80,-27):
			max_change=maxf(max_change,absf(surface.height_at(x,z,true)-baseline.height_at(x,z,true)))
	for road in surface.named_routes:
		for at in road.points:
			max_road=maxf(max_road,absf(surface.height_at(at.x,at.y,true)-baseline.height_at(at.x,at.y,true)))
	print("TERRACE90_SURFACE ",JSON.stringify({"grove":g,"max_battle_height_delta":max_field,"max_geometry_change":max_change,"max_road_delta":max_road,"west_top":surface.height_at(-76.,g.y,true),"rear_top":surface.height_at(-50.,-75.,true)}))
	quit(0 if max_field<.08 and max_road<.08 and max_change>1. else 1)
