extends "res://scripts/world/world_surface84.gd"
func _init() -> void:
	super._init()
	for route in named_routes:
		if route.name!="junction_to_station": continue
		var previous: PackedVector2Array=route.controls
		# Enter the east-facing flight from its foot, rather than climbing through
		# the southern side cheek as the old smooth shoulder allowed.
		var controls := PackedVector2Array([previous[0],previous[1],Vector2(11.7,-42.8),Vector2(11.7,-45.9),SIDE_FOOT75])
		for i in range(3,previous.size()): controls.append(previous[i])
		route.controls=controls;route.points=_smooth(controls)
	_reindex_routes()
