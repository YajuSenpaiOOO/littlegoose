extends "res://scripts/world/world_surface76.gd"
var road_endings77: Array[Vector4]=[]

func named_road77(name: String) -> Dictionary:
	for entry in named_routes:
		if entry.name==name: return entry
	return {}

func closest_on_road77(at: Vector2,name: String) -> Vector2:
	var road: Dictionary=named_road77(name)
	var closest := at;var distance := INF
	for i in range(1,road.points.size()):
		var point: Vector2=Geometry2D.get_closest_point_to_segment(at,road.points[i-1],road.points[i])
		if point.distance_squared_to(at)<distance: distance=point.distance_squared_to(at);closest=point
	return closest

func _init() -> void:
	super._init()
	var bypass: Dictionary=named_road77("woodland_return72")
	# A path branch starts on a real path, not eight metres away in bare grass.
	bypass.controls[0]=closest_on_road77(bypass.controls[0],"junction_to_grove")
	bypass.controls[-1]=closest_on_road77(bypass.controls[-1],"junction_ring")
	bypass.points=_smooth(bypass.controls)
	var landing: Dictionary=named_road77("home_to_landing")
	landing.controls[0]=closest_on_road77(landing.controls[0],"home_to_junction")
	landing.points=_smooth(landing.controls)
	_reindex_routes()
	# These are deliberate destinations in open ground; worn soil dissolves
	# into the clearing instead of finishing in a hard round drawing-tool cap.
	for spec in [["junction_to_grove",4.5],["junction_to_shore",4.0],["home_to_landing",1.4]]:
		var road: Dictionary=named_road77(spec[0])
		var end: Vector2=road.points[-1]
		road_endings77.append(Vector4(end.x,end.y,spec[1],0.))

func road_finish77(at: Vector2) -> float:
	var amount := 1.
	for end in road_endings77: amount=minf(amount,smoothstep(.15,end.z,at.distance_to(Vector2(end.x,end.y))))
	return amount
