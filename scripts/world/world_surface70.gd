extends "res://scripts/world/world_surface69.gd"
## An authored raised clearing, not a road ring. Shared by rendering and physics.
const LEVEL70 := 2.65
const OUTLINE70 := [Vector2(-12,-5),Vector2(-7,-8),Vector2(5,-7.5),Vector2(10,-4),Vector2(10,2),Vector2(7,5.5),Vector2(1,6.8),Vector2(-6,7),Vector2(-12,4)]
var outline70 := PackedVector2Array(OUTLINE70)

func _init() -> void:
	super._init()
	var g: Vector2=landmarks.grove
	var hub: Vector2=landmarks.junction
	for i in range(named_routes.size()-1,-1,-1):
		if named_routes[i].name in ["grove_side_loop69","grove_return69"]: named_routes.remove_at(i)
	for entry in named_routes:
		if entry.name=="junction_to_grove":
			entry.controls=PackedVector2Array([hub+Vector2(-10,0),hub+Vector2(-15,1.2),g+Vector2(23,10),g+Vector2(15,12),g+Vector2(5,14),g+Vector2(-3,14),g+Vector2(-3,6),g+Vector2(-3,3)])
			entry.points=_smooth(entry.controls); entry.radius=1.15
	var route70 := PackedVector2Array([g+Vector2(6,0),g+Vector2(10,0),g+Vector2(18,0),g+Vector2(21,4),g+Vector2(23,10)])
	named_routes.append({"name":"grove_side_descent70","controls":route70,"points":_smooth(route70),"radius":1.})
	_reindex_routes()

func edge70(p: Vector2) -> float:
	var nearest := 100.
	for i in outline70.size():
		var a := outline70[i]
		var b := outline70[(i+1)%outline70.size()]
		nearest=minf(nearest,p.distance_to(Geometry2D.get_closest_point_to_segment(p,a,b)))
	return -nearest if Geometry2D.is_point_in_polygon(p,outline70) else nearest

func stair70(p: Vector2) -> bool:
	return absf(p.x+3.)<1.85 and p.y>=6.2 and p.y<=14.2

func side70(p: Vector2) -> bool:
	return p.x>=8.5 and p.x<=18.8 and absf(p.y)<2.15

func is_open_ground(at: Vector2) -> bool:
	var p: Vector2=at-landmarks.grove
	if p.x>-18 and p.x<26 and p.y>-15 and p.y<20:
		return edge70(p)<1.3 or route_distance(at)<2.3 or (p.y>6 and p.y<19 and absf(p.x+3.)<5.5)
	return super.is_open_ground(at)

func height_at(x: float,z: float,enabled: bool) -> float:
	var base := super.height_at(x,z,enabled)
	if not enabled or landmarks.is_empty(): return base
	var p := Vector2(x,z)-Vector2(landmarks.grove)
	if absf(p.x)>27 or absf(p.y)>21: return base
	# Remove the previous low dome completely before authoring the new levels.
	var lower := .14+.035*sin(x*.22)*sin(z*.19)
	var local_weight := (1.-smoothstep(24.,27.,absf(p.x)))*(1.-smoothstep(18.,21.,absf(p.y)))
	var h := lower
	if p.x>-14 and p.x<12 and p.y>-10 and p.y<9:
		h=lerpf(lower,LEVEL70,1.-smoothstep(-.22,.18,edge70(p)))
	if absf(p.x+3.)<2.35 and p.y>5.8 and p.y<14.5:
		var ramp := lerpf(LEVEL70,lower,clampf((p.y-6.3)/7.7,0.,1.))
		h=lerpf(h,ramp,1.-smoothstep(1.8,2.3,absf(p.x+3.)))
	if p.x>8. and p.x<19. and absf(p.y)<2.7:
		var ramp := lerpf(LEVEL70,lower,smoothstep(9.,18.5,p.x))
		h=lerpf(h,ramp,1.-smoothstep(2.0,2.7,absf(p.y)))
	return lerpf(base,h,local_weight)
