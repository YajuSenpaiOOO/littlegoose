extends "res://scripts/world/world_surface74.gd"
const SIDE_FOOT75 := Vector2(10.,-45.9)
const SIDE_TOP75 := Vector2(4.8,-45.9)
var hall_reserve75 := Rect2()
var platform_reserve75 := Rect2()

func _init() -> void:
	super._init()
	# Grow the depth behind the existing forecourt, without widening it again.
	rail_z73-=12.
	rail_alignment73=Vector2(world_bounds.position.x,world_bounds.end.x)
	rail_rect72=Rect2(Vector2(portal_x73-1.,rail_z73-3.2),Vector2(world_bounds.end.x-portal_x73+1.,6.4))
	train_clearance72=Rect2(Vector2(portal_x73,rail_z73-2.),Vector2(world_bounds.end.x-portal_x73,4.))
	var station: Vector2=landmarks.station
	station_rect73=Rect2(Vector2(station.x-20.,rail_z73-4.),Vector2(40.,station.y+10.2-rail_z73+4.))
	hall_reserve75=Rect2(station+Vector2(-10.,-10.7),Vector2(20.,9.))
	platform_reserve75=Rect2(Vector2(station.x-18.,rail_z73+3.2),Vector2(36.,4.5))
	for entry in named_routes:
		if entry.name=="junction_to_station":
			var hub: Vector2=landmarks.junction
			entry.controls=PackedVector2Array([hub+Vector2(0,-8.8),Vector2(10.,hub.y-8.8),SIDE_FOOT75,SIDE_TOP75,Vector2(4.8,-51.),station+Vector2(-7.,17.),station+Vector2(0,13.),station+Vector2(0,9.),station+Vector2(0,1.35)])
			entry.points=_smooth(entry.controls)
	_reindex_routes()

func station_stair_run74() -> float: return 3.4
func station_stair_count74() -> int: return 7
func stair_start73() -> Vector2:
	return Vector2(landmarks.station.x,station_front74(landmarks.station.x)+2.95)

func wall_weight75(x: float) -> float:
	return smoothstep(-14.,-5.,x)*(1.-smoothstep(15.,24.,x))

func regional_front75(x: float) -> float:
	return lerpf(front72(x),-47.5,wall_weight75(x))

func _main_half_width75(x: float,_z: float,road: float) -> float:
	return lerpf(lerpf(2.8,6.,road),.18,wall_weight75(x))

func is_open_ground(at: Vector2) -> bool:
	if Rect2(Vector2(1.5,-51.),Vector2(12.,9.)).has_point(at): return true
	if at.x> -5. and at.x<20. and absf(at.y+47.5)<3.: return true
	return super.is_open_ground(at)

func _terrain_divisions19(rect: Rect2,ids: Array[int]) -> int:
	if rect.intersects(Rect2(Vector2(-7.,-52.),Vector2(30.,12.))): return 64
	return super._terrain_divisions19(rect,ids)

func height_at(x: float,z: float,enabled: bool) -> float:
	var original: float=shore_base73.height_at(x,z,enabled)
	if not enabled or landmarks.is_empty(): return original
	var at := Vector2(x,z)
	if is_water(at) or (x>15. and z> -43.): return original
	var road := 1.-smoothstep(1.05,3.1,route_distance(at))
	# Natural edges become shoulders, while the short maintained road section
	# has one definite retaining edge. Neither follows a combat-area perimeter.
	var half_width := _main_half_width75(x,z,road)
	var main := 1.-smoothstep(-half_width,half_width,z-regional_front75(x))
	var h := LOW72+(MAIN72-LOW72)*main
	var upper := (1.-smoothstep(-3.8,3.8,z-upper_front73(x)))*(1.-smoothstep(-28.,-13.,x))
	h+=(UPPER72-MAIN72)*upper
	# Sideways flight climbs east-to-west along the existing terrace front.
	var side_t := clampf((SIDE_FOOT75.x-x)/5.2,0.,1.)
	var side_h := lerpf(LOW72,MAIN72,side_t)
	var side_weight := (1.-smoothstep(1.15,1.65,absf(z-SIDE_FOOT75.y)))*smoothstep(2.6,3.6,x)*(1.-smoothstep(10.1,11.,x))
	h=maxf(h,lerpf(LOW72,side_h,side_weight))
	# The upper landing is a widening of the regional shelf, open to the north.
	var apron := (1.-smoothstep(.95,1.6,absf(x-SIDE_TOP75.x)))*(1.-smoothstep(-45.4,-44.7,z))
	# Do not let the landing blend form a steeper hidden lip across the flight.
	h=maxf(h,lerpf(LOW72,side_h,apron))
	var western := smoothstep(-32.,-14.,x)
	var front := station_front74(x)
	var edge_width := lerpf(3.2,.18,smoothstep(-16.,-9.,x))
	var upper_shelf := western*(1.-smoothstep(-edge_width,edge_width,z-front))
	h=maxf(h,lerpf(MAIN72,STATION_LEVEL73,upper_shelf)) if main>.99 else h
	var rail_outside := (at-rail_rect72.get_center()).abs()-rail_rect72.size*.5
	h=lerpf(h,STATION_LEVEL73,1.-smoothstep(0.,2.3,rail_outside.max(Vector2.ZERO).length()))
	var dx: float=absf(x-landmarks.station.x)
	if dx<3.2 and z>front-.5 and z<front+3.2:
		var stair_h := lerpf(STATION_LEVEL73,MAIN72,clampf((z-front+.45)/station_stair_run74(),0.,1.))
		h=lerpf(h,stair_h,1.-smoothstep(2.3,3.2,dx))
	var home: Vector2=landmarks.home
	h=lerpf(h,.12,1.-smoothstep(5.8,8.8,at.distance_to(home)))
	var hub_ring := ((at-Vector2(landmarks.junction))/Vector2(11.6,10.4)).length()
	var hub_weight := (1.-smoothstep(1.,1.65,hub_ring))*smoothstep(-45.,-42.,z)
	h=lerpf(h,LOW72,hub_weight)
	return lerpf(h,original,smoothstep(7.,15.,x)*smoothstep(-47.,-43.,z))
