extends "res://scripts/world/world_surface69.gd"
## The clearing is a hole in an upland forest, not a raised arena polygon.
const FOREST_LEVEL71 := 2.35

func _init() -> void:
	super._init()
	var g: Vector2=landmarks.grove
	var hub: Vector2=landmarks.junction
	for i in range(named_routes.size()-1,-1,-1):
		if named_routes[i].name in ["grove_side_loop69","grove_return69"]: named_routes.remove_at(i)
	for entry in named_routes:
		if entry.name=="junction_to_grove":
			entry.controls=PackedVector2Array([hub+Vector2(-10,0),hub+Vector2(-15,1.2),g+Vector2(25,9),g+Vector2(16,13),g+Vector2(5,14),g+Vector2(-3,14),g+Vector2(-3,6),g+Vector2(-5,2)])
			entry.points=_smooth(entry.controls); entry.radius=1.05
	var descent := PackedVector2Array([g+Vector2(5,-1),g+Vector2(12,-2),g+Vector2(20,-1),g+Vector2(26,5),g+Vector2(25,9)])
	named_routes.append({"name":"woodland_east_slope71","controls":descent,"points":_smooth(descent),"radius":.9})
	_reindex_routes()

func front71(x: float) -> float:
	return 7.+1.6*sin((x+4.)*.13)+.6*sin(x*.34)

func upland71(p: Vector2) -> float:
	# The rear and west do not descend at the combat boundary: they continue
	# through the surrounding trees and rise into wooded foothills.
	return FOREST_LEVEL71+.045*sin(p.x*.22)*sin(p.y*.18)+1.35*smoothstep(7.,23.,-p.y)

func is_open_ground(at: Vector2) -> bool:
	var p: Vector2=at-landmarks.grove
	if p.x>-31 and p.x<30 and p.y>-29 and p.y<23:
		var clearing := ((p-Vector2(-1,0))/Vector2(9.8,6.0)).length()<1.
		var entrance := p.y>5. and p.y<19. and absf(p.x+3.)<5.5
		return clearing or entrance or route_distance(at)<2.05
	return super.is_open_ground(at)

func height_at(x: float,z: float,enabled: bool) -> float:
	var base := super.height_at(x,z,enabled)
	if not enabled or landmarks.is_empty(): return base
	var p := Vector2(x,z)-Vector2(landmarks.grove)
	if p.x>31 or p.y>23 or is_water(Vector2(x,z)): return base
	var region := (1.-smoothstep(27.,31.,p.x))*(1.-smoothstep(20.,23.,p.y))
	var lower := .16+.035*sin(x*.22)*sin(z*.19)
	var edge := p.y-front71(p.x)
	var front := 1.-smoothstep(-.15,.35,edge)
	var east := 1.-smoothstep(12.,27.,p.x)
	var h := lerpf(lower,upland71(p),front*east)
	if absf(p.x+3.)<2.35 and p.y>5.8 and p.y<14.5:
		var ramp := lerpf(FOREST_LEVEL71,lower,clampf((p.y-6.3)/7.7,0.,1.))
		h=lerpf(h,ramp,1.-smoothstep(1.8,2.3,absf(p.x+3.)))
	return lerpf(base,h,region)
