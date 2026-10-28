extends "res://scripts/world/world_surface63.gd"
const GROVE_LEVEL69 := .62
const STATION_LEVEL69 := 1.25
const APRON_LEVEL69 := .55

func _init() -> void:
	super._init()
	var hub: Vector2=landmarks.junction
	var grove: Vector2=landmarks.grove
	var station: Vector2=landmarks.station
	for entry in named_routes:
		if entry.name=="junction_to_grove":
			entry.controls=PackedVector2Array([hub+Vector2(-10,0),hub+Vector2(-15,1.2),grove+Vector2(21,6),grove+Vector2(15,5),grove+Vector2(11,6)])
			entry.points=_smooth(entry.controls); entry.radius=1.05
		elif entry.name=="junction_to_station":
			entry.controls=PackedVector2Array([hub+Vector2(0,-8.8),hub+Vector2(-3,-12),hub+Vector2(-3.2,-15.3),station+Vector2(-1.4,4.5),station+Vector2(2,3),station+Vector2(0,1.35)])
			entry.points=_smooth(entry.controls); entry.radius=1.15
	var loop := PackedVector2Array()
	for p in [Vector2(11,6),Vector2(3,10),Vector2(-8,9),Vector2(-13,1),Vector2(-9,-7.5),Vector2(2,-9.5),Vector2(12,-4),Vector2(14,3),Vector2(11,6)]: loop.append(grove+p)
	named_routes.append({"name":"grove_side_loop69","controls":loop,"points":_smooth(loop),"radius":.65})
	var exit := PackedVector2Array([grove+Vector2(12,-4),grove+Vector2(17,-5.5),hub+Vector2(-16,-8),hub+Vector2(-12,-6),hub+Vector2(-9,-3.5)])
	named_routes.append({"name":"grove_return69","controls":exit,"points":_smooth(exit),"radius":1.})
	_reindex_routes()

func box_weight69(at: Vector2,rect: Rect2,falloff: float) -> float:
	var outside := (at-rect.get_center()).abs()-rect.size*.5
	return 1.-smoothstep(0.,falloff,outside.max(Vector2.ZERO).length())

func height_at(x: float,z: float,enabled: bool) -> float:
	var base := super.height_at(x,z,enabled)
	if not enabled or landmarks.is_empty(): return base
	var at := Vector2(x,z)
	if is_water(at) or bridge_rect.grow(1.5).has_point(at): return base
	var grove: Vector2=landmarks.grove
	var station: Vector2=landmarks.station
	var ring := ((at-grove)/Vector2(10.5,7.)).length()
	base=lerpf(base,GROVE_LEVEL69,1.-smoothstep(1.,1.5,ring))
	var apron := Rect2(station+Vector2(-8,3.5),Vector2(16,6.5))
	base=lerpf(base,APRON_LEVEL69,box_weight69(at,apron,3.5))
	var platform := Rect2(station+Vector2(-9,-5.2),Vector2(18,7.))
	base=lerpf(base,STATION_LEVEL69,box_weight69(at,platform,3.5))
	var verge := smoothstep(1.2,3.,route_distance(at))
	var north_bank := (at-grove-Vector2(-3,-12))/Vector2(11,4.)
	var south_bank := (at-grove-Vector2(1,12))/Vector2(10,3.5)
	base+=(1.05*exp(-north_bank.length_squared()*2.)+.65*exp(-south_bank.length_squared()*2.))*verge
	var station_bank := (at-station-Vector2(8,10))/Vector2(5.5,4.)
	base+=.85*exp(-station_bank.length_squared()*2.)*verge
	return base
