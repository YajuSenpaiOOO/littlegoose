extends "res://scripts/world/world_surface72.gd"
const GROVE_RADII73 := Vector2(15.,10.)
const STATION_LEVEL73 := 3.40
var rail_z73 := RAIL_Z72-18.
var portal_x73 := -28.
var rail_alignment73 := Vector2.ZERO
var station_rect73 := Rect2()
var shore_base73=preload("res://scripts/world/world_surface63.gd").new()
var terrain_build73 := false

func rail_level73() -> float: return RAIL72

func _init() -> void:
	super._init()
	var old_g: Vector2=landmarks.grove
	var old_station: Vector2=landmarks.station
	landmarks.grove+=Vector2(-9,-5)
	landmarks.station+=Vector2(6,-18)
	landmarks.junction+=Vector2(0,-3)
	world_bounds.position.x-=14.; world_bounds.size.x+=14.
	world_bounds.position.y-=22.; world_bounds.size.y+=22.
	rail_alignment73=Vector2(world_bounds.position.x-48.,world_bounds.end.x+48.)
	rail_rect72=Rect2(Vector2(portal_x73-1.,rail_z73-3.2),Vector2(rail_alignment73.y-portal_x73+1.,6.4))
	train_clearance72=Rect2(Vector2(portal_x73,rail_z73-2.),Vector2(rail_alignment73.y-portal_x73,4.))
	var g: Vector2=landmarks.grove
	var hub: Vector2=landmarks.junction
	var station: Vector2=landmarks.station
	station_rect73=Rect2(station+Vector2(-10,-6.3),Vector2(20,9.5))
	for c in clearings:
		if c.at.distance_to(old_g)<1.: c.at=g; c.radius=GROVE_RADII73
		elif c.at.distance_to(old_station)<3.: c.at=station+Vector2(0,1.35)
	for entry in named_routes:
		match entry.name:
			"home_to_junction":
				entry.controls[0]=Vector2(-4.7,-2.5)
				entry.controls[-1]=hub+Vector2(0,8.8)
				main_route=entry.controls; route=_smooth(entry.controls)
			"junction_ring":
				for i in entry.controls.size(): entry.controls[i]+=Vector2(0,-3)
			"junction_to_grove":
				entry.controls=PackedVector2Array([hub+Vector2(-10,0),hub+Vector2(-18,3),Vector2(-28,-33),g+Vector2(16,8),g+Vector2(10,4),g+Vector2(0,3),g])
			"junction_to_station":
				entry.controls=PackedVector2Array([hub+Vector2(0,-8.8),hub+Vector2(-4,-14),hub+Vector2(1,-21),station+Vector2(-8,13),station+Vector2(-5,8),station+Vector2(0,7.8),station+Vector2(0,2.2),station+Vector2(0,1.35)])
			"junction_to_shore": entry.controls[0]=hub+Vector2(10,0)
			"woodland_return72":
				entry.controls=PackedVector2Array([g+Vector2(12,-3),hub+Vector2(-26,-14),hub+Vector2(-18,-10),hub+Vector2(-12,-3)])
		entry.points=entry.controls if entry.name=="junction_ring" else _smooth(entry.controls)
	_reindex_routes()

func upper_front73(x: float) -> float:
	return front72(x)-30.

func stair_start73() -> Vector2:
	return Vector2(landmarks.station.x,station_rect73.end.y+5.5)

func station_cap73(at: Vector2) -> bool:
	return station_rect73.has_point(at) and (absf(at.x-landmarks.station.x)>=2.8 or at.y<station_rect73.end.y-.8)

func terrain(enabled: bool) -> ArrayMesh:
	# The station is masonry on ground, rather than a grass mound hidden behind
	# thin painted sides. Its three solid cap bodies carry the elevated floor.
	terrain_build73=true
	var result := super.terrain(enabled)
	terrain_build73=false
	return result

func is_open_ground(at: Vector2) -> bool:
	if rail_rect72.grow(2.2).has_point(at) or station_rect73.grow(2.).has_point(at): return true
	if normal_at(at.x,at.y,true).y<.88: return true
	if at.x< -14. and absf(at.y-upper_front73(at.x))<3.4: return true
	if absf(at.y-front72(at.x))<2.2 and route_distance(at)>1.4: return true
	var g: Vector2=landmarks.grove
	if at.distance_to(g)<28.: return ((at-g)/GROVE_RADII73).length()<1. or route_distance(at)<2.
	for c in clearings:
		if ((at-c.at)/c.radius).length()<1.: return true
	return ((at-Vector2(landmarks.junction))/(HUB_RADII63+Vector2(2.7,2.7))).length()<1.

func height_at(x: float,z: float,enabled: bool) -> float:
	var original: float=shore_base73.height_at(x,z,enabled)
	if not enabled or landmarks.is_empty(): return original
	var at := Vector2(x,z)
	if is_water(at) or (x>15. and z> -43.): return original
	var road := 1.-smoothstep(1.05,3.1,route_distance(at))
	var half_width := lerpf(.85,6.,road)
	var main := 1.-smoothstep(-half_width,half_width,z-front72(x))
	var h := LOW72+(MAIN72-LOW72)*main
	var upper := (1.-smoothstep(-1.4,1.4,z-upper_front73(x)))*(1.-smoothstep(-28.,-13.,x))
	h+=(UPPER72-MAIN72)*upper
	var rail_outside := (at-rail_rect72.get_center()).abs()-rail_rect72.size*.5
	h=lerpf(h,RAIL72,1.-smoothstep(0.,2.3,rail_outside.max(Vector2.ZERO).length()))
	var outside := (at-station_rect73.get_center()).abs()-station_rect73.size*.5
	h=lerpf(h,STATION_LEVEL73,1.-smoothstep(0.,.12,outside.max(Vector2.ZERO).length()))
	var front := station_rect73.end.y
	var relative_x: float=absf(x-landmarks.station.x)
	if relative_x<2.8 and z>front-.8 and z<front+5.7:
		var stair_h := lerpf(STATION_LEVEL73,MAIN72,clampf((z-front+.6)/6.1,0.,1.))
		h=lerpf(h,stair_h,1.-smoothstep(2.15,2.8,relative_x))
	if terrain_build73 and station_cap73(at): h=MAIN72
	var home: Vector2=landmarks.home
	h=lerpf(h,.12,1.-smoothstep(5.8,8.8,at.distance_to(home)))
	var hub_ring := ((at-Vector2(landmarks.junction))/Vector2(11.6,10.4)).length()
	h=lerpf(h,LOW72,1.-smoothstep(1.,1.25,hub_ring))
	return lerpf(h,original,smoothstep(7.,15.,x)*smoothstep(-47.,-43.,z))
