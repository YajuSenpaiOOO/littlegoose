extends "res://scripts/world/world_surface73.gd"
## A regional upper shelf continues behind the plaza and supports the railway.
## Paving bounds never define the bounds of the land itself.
func _init() -> void:
	super._init()
	var station: Vector2=landmarks.station
	station_rect73=Rect2(Vector2(station.x-20.,rail_z73-4.),Vector2(40.,station.y+10.2-rail_z73+4.))
	for entry in named_routes:
		if entry.name=="junction_to_station":
			var hub: Vector2=landmarks.junction
			entry.controls=PackedVector2Array([hub+Vector2(0,-8.8),hub+Vector2(-6,-13),station+Vector2(-9,21),station+Vector2(-7,17),station+Vector2(0,16.5),station+Vector2(0,9),station+Vector2(0,1.35)])
			entry.points=_smooth(entry.controls)
	_reindex_routes()

func rail_level73() -> float: return STATION_LEVEL73
func station_stair_run74() -> float: return 6.75
func station_stair_count74() -> int: return 9
func station_cap73(_at: Vector2) -> bool: return false

func terrain(enabled: bool) -> ArrayMesh:
	# Bypass the former hollow foundation: the actual terrain carries the plaza.
	return super.terrain(enabled)

func station_front74(x: float) -> float:
	# The exposed front extends sideways into the landscape, not around a box.
	var station: Vector2=landmarks.station
	return station.y+10.-3.*smoothstep(station.x+20.,station.x+44.,x)

func stair_start73() -> Vector2:
	return Vector2(landmarks.station.x,station_front74(landmarks.station.x)+6.1)

func _terrain_divisions19(rect: Rect2,ids: Array[int]) -> int:
	return 64 if rect.intersects(station_rect73.grow(8.)) else super._terrain_divisions19(rect,ids)

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
	# This half-plane continues to the north/east world boundary. The broad
	# western transition ties it to the woodland shelf rather than ending it.
	var western := smoothstep(-32.,-14.,x)
	var front := station_front74(x)
	var edge_width := lerpf(3.2,.18,smoothstep(-16.,-9.,x))
	var upper_shelf := western*(1.-smoothstep(-edge_width,edge_width,z-front))
	h=maxf(h,lerpf(MAIN72,STATION_LEVEL73,upper_shelf)) if main>.99 else h
	# Flatten only the rail cutting through the higher rear forest. It stays at
	# the plaza level, and the land behind still rises to the rear woodland.
	var rail_outside := (at-rail_rect72.get_center()).abs()-rail_rect72.size*.5
	h=lerpf(h,STATION_LEVEL73,1.-smoothstep(0.,2.3,rail_outside.max(Vector2.ZERO).length()))
	var dx: float=absf(x-landmarks.station.x)
	if dx<3.2 and z>front-.9 and z<front+6.5:
		var stair_h := lerpf(STATION_LEVEL73,MAIN72,clampf((z-front+.65)/6.75,0.,1.))
		h=lerpf(h,stair_h,1.-smoothstep(2.3,3.2,dx))
	var home: Vector2=landmarks.home
	h=lerpf(h,.12,1.-smoothstep(5.8,8.8,at.distance_to(home)))
	var hub_ring := ((at-Vector2(landmarks.junction))/Vector2(11.6,10.4)).length()
	h=lerpf(h,LOW72,1.-smoothstep(1.,1.25,hub_ring))
	return lerpf(h,original,smoothstep(7.,15.,x)*smoothstep(-47.,-43.,z))
