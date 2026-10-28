extends "res://scripts/world/world_surface63.gd"
## One regional height system for the whole existing map. No arena-height island.
const LOW72 := .20
const MAIN72 := 2.10
const UPPER72 := 6.25
const RAIL72 := 2.10
const RAIL_Z72 := -61.4
var rail_rect72 := Rect2(Vector2(-22.,-64.6),Vector2(54.,6.4))
var train_clearance72 := Rect2(Vector2(-22.,-63.4),Vector2(54.,4.0))

func _init() -> void:
	super._init()
	# Extend only the northern background; no gameplay area is squeezed.
	world_bounds.position.y-=12.; world_bounds.size.y+=12.
	var g: Vector2=landmarks.grove
	var hub: Vector2=landmarks.junction
	var station: Vector2=landmarks.station
	for entry in named_routes:
		if entry.name=="junction_to_grove":
			entry.controls=PackedVector2Array([hub+Vector2(-10,0),hub+Vector2(-16,1),Vector2(-25,-31),Vector2(-31,-33),g+Vector2(7,3),g+Vector2(0,3),g])
			entry.points=_smooth(entry.controls); entry.radius=1.1
		elif entry.name=="junction_to_station":
			entry.controls=PackedVector2Array([hub+Vector2(0,-8.8),station+Vector2(-3,12),station+Vector2(-2,8),station+Vector2(1,4),station+Vector2(0,1.35)])
			entry.points=_smooth(entry.controls); entry.radius=1.15
		elif entry.name=="home_to_landing":
			entry.controls=PackedVector2Array([landmarks.home+Vector2(6,5),Vector2(5,.7),Vector2(10,0),landmarks.landing])
			entry.points=_smooth(entry.controls); entry.radius=.8
	var bypass := PackedVector2Array([g+Vector2(9,-3),hub+Vector2(-20,-12),hub+Vector2(-14,-9),hub+Vector2(-12,-3)])
	named_routes.append({"name":"woodland_return72","controls":bypass,"points":_smooth(bypass),"radius":.85})
	_reindex_routes()

func front72(x: float) -> float:
	return lerpf(-29.5,-46.,smoothstep(-36.,7.,x))+.6*sin(x*.11)

func _terrain_divisions19(rect: Rect2,ids: Array[int]) -> int:
	# Resolve the train/platform clearance in the actual physics mesh, not just
	# in the mathematical height function; coarse triangles must not smear it.
	return 64 if rect.intersects(rail_rect72.grow(1.5)) else super._terrain_divisions19(rect,ids)

func is_open_ground(at: Vector2) -> bool:
	if rail_rect72.grow(2.2).has_point(at): return true
	if normal_at(at.x,at.y,true).y<.88: return true
	# Painted roots have a footprint, not just a point. Leave room behind cut
	# edges so a correctly grounded trunk does not hang its root card over air.
	if at.x< -14. and absf(at.y-front72(at.x)+19.)<3.4: return true
	if absf(at.y-front72(at.x))<2.2 and route_distance(at)>1.4: return true
	var g: Vector2=landmarks.grove
	if at.distance_to(g)<23.:
		return ((at-g)/Vector2(12.5,8.0)).length()<1. or route_distance(at)<2.
	return super.is_open_ground(at)

func height_at(x: float,z: float,enabled: bool) -> float:
	var original := super.height_at(x,z,enabled)
	if not enabled or landmarks.is_empty(): return original
	var at := Vector2(x,z)
	if is_water(at): return original
	# Approved water/bridge/landing connections retain their established baseline.
	if x>15. and z> -43.: return original
	var road := 1.-smoothstep(1.05,3.1,route_distance(at))
	var half_width := lerpf(.85,6.,road)
	var main := 1.-smoothstep(-half_width,half_width,z-front72(x))
	var h := LOW72+(MAIN72-LOW72)*main
	# The higher forest is an actual broad top, continuing beyond the clearing.
	# It tapers towards the station instead of becoming a separate rock mountain.
	var upper_west := 1.-smoothstep(-28.,-13.,x)
	var upper_edge := front72(x)-19.
	var upper := (1.-smoothstep(-1.4,1.4,z-upper_edge))*upper_west
	h+=(UPPER72-MAIN72)*upper
	# Stable, real space for tracks / train clearance / platform rear edge.
	var rail_outside := (at-rail_rect72.get_center()).abs()-rail_rect72.size*.5
	var rail_weight := 1.-smoothstep(0.,2.3,rail_outside.max(Vector2.ZERO).length())
	h=lerpf(h,RAIL72,rail_weight)
	# A compact platform alongside the rail corridor; the forecourt belongs to
	# the same MAIN72 shelf as the forest, rather than a separate station mound.
	var station: Vector2=landmarks.station
	var platform := Rect2(station+Vector2(-9,-6.3),Vector2(18,3.0))
	var outside := (at-platform.get_center()).abs()-platform.size*.5
	var platform_weight := 1.-smoothstep(0.,.12,outside.max(Vector2.ZERO).length())
	h=lerpf(h,MAIN72+.35,platform_weight)
	# Local grading at approved home and great-tree roots, not independent hills.
	var home: Vector2=landmarks.home
	h=lerpf(h,.12,1.-smoothstep(5.8,8.8,at.distance_to(home)))
	var hub: Vector2=landmarks.junction
	var hub_ring := ((at-hub)/Vector2(11.6,10.4)).length()
	h=lerpf(h,LOW72,1.-smoothstep(1.,1.25,hub_ring))
	# Blend into the retained lakeside grading instead of introducing a seam
	# where the construction region meets approved bridge / shore geometry.
	var shore := smoothstep(7.,15.,x)*smoothstep(-47.,-43.,z)
	return lerpf(h,original,shore)
