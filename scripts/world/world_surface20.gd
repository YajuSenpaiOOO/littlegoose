extends "res://scripts/world/world_surface19.gd"
## Structural rehearsal: the four spokes join a ring; the grove has one ramped entrance.
const RING_RADIUS := 6.2
const GROVE_RADII := Vector2(12.,8.5)
const GROVE_LEVEL := 1.92
const STAIR_OUTER := 17.
const STAIR_INNER := 9.5
const STAIR_WIDTH := 3.2
var stair_direction := Vector2.RIGHT
var terrace_enabled := true

func _init() -> void:
	super._init()
	var hub: Vector2 = landmarks.junction
	for entry in named_routes:
		var controls: PackedVector2Array = entry.controls
		match entry.name:
			"home_to_junction": controls[-1] = hub+Vector2(0,RING_RADIUS)
			"junction_to_station": controls[0] = hub-Vector2(0,RING_RADIUS)
			"junction_to_grove":
				controls[0] = hub-Vector2(RING_RADIUS,0)
				stair_direction = (controls[-2]-landmarks.grove).normalized()
				controls.resize(5)
				controls.append(landmarks.grove+stair_direction*STAIR_OUTER)
				controls.append(landmarks.grove+stair_direction*STAIR_INNER)
				controls.append(landmarks.grove)
			"junction_to_shore": controls[0] = hub+Vector2(RING_RADIUS,0)
		entry.controls = controls
		entry.points = _smooth(controls)
		if entry.name=="home_to_junction":
			main_route = controls
			route = entry.points
	var circle := PackedVector2Array()
	for i in 25:
		var angle := TAU*float(i)/24.
		circle.append(hub+Vector2(sin(angle),cos(angle))*RING_RADIUS)
	named_routes.append({"name":"junction_ring","controls":circle,"points":circle,"radius":1.05})
	_reindex_routes()

func _reindex_routes() -> void:
	segments.clear()
	bins.clear()
	mesh_cache.clear()
	for entry in named_routes:
		var points: PackedVector2Array = entry.points
		for i in range(points.size()-1):
			var index := segments.size()
			segments.append({"a":points[i],"b":points[i+1],"radius":entry.radius,"route":entry.name})
			var lo := points[i].min(points[i+1])-Vector2.ONE*5.
			var hi := points[i].max(points[i+1])+Vector2.ONE*5.
			for z in range(floori(lo.y/CELL),floori(hi.y/CELL)+1):
				for x in range(floori(lo.x/CELL),floori(hi.x/CELL)+1):
					var key := Vector2i(x,z)
					if not bins.has(key): bins[key] = []
					bins[key].append(index)

func is_open_ground(at: Vector2) -> bool:
	var p := stair_coordinates(at)
	if terrace_enabled and p.x>7. and p.x<21. and absf(p.y)<5.: return true
	var entrance: Vector2 = landmarks.grove+stair_direction*13.
	var front := at-entrance
	if terrace_enabled and front.y>0. and front.y<13. and absf(front.x)<3.+front.y*.55: return true
	return at.distance_to(landmarks.junction)<RING_RADIUS+2.8 or super.is_open_ground(at)

func stair_coordinates(at: Vector2) -> Vector2:
	var delta: Vector2 = at-landmarks.grove
	return Vector2(delta.dot(stair_direction),delta.dot(Vector2(-stair_direction.y,stair_direction.x)))

func is_stair(at: Vector2) -> bool:
	if not terrace_enabled: return false
	var p := stair_coordinates(at)
	return p.x>=STAIR_INNER and p.x<=STAIR_OUTER and absf(p.y)<STAIR_WIDTH*.5+.15

func contains_soil(at: Vector2) -> bool:
	return not is_stair(at) and super.contains_soil(at)

func height_at(x: float,z: float,enabled: bool) -> float:
	var base := super.height_at(x,z,enabled)
	if not enabled or not terrace_enabled or landmarks.is_empty(): return base
	var at := Vector2(x,z)
	var delta: Vector2 = at-landmarks.grove
	var edge := ((delta/GROVE_RADII).length()-1.)*GROVE_RADII.y
	var weight := 1.-smoothstep(0.,.65,edge)
	var result := lerpf(base,GROVE_LEVEL,weight)
	var p := stair_coordinates(at)
	if p.x>=STAIR_INNER and p.x<=STAIR_OUTER:
		var along := clampf((STAIR_OUTER-p.x)/(STAIR_OUTER-STAIR_INNER),0.,1.)
		var outer: Vector2 = landmarks.grove+stair_direction*STAIR_OUTER
		var bottom := super.height_at(outer.x,outer.y,true)
		var ramp := lerpf(bottom,GROVE_LEVEL,along)
		var side := 1.-smoothstep(STAIR_WIDTH*.5-.10,STAIR_WIDTH*.5+.20,absf(p.y))
		result = lerpf(result,ramp,side)
	return result
