extends "res://scripts/world/world_surface96.gd"
const PARK97=preload("res://scripts/world/park_layout97.gd")
func _init() -> void:
	super._init()
	var g: Vector2=landmarks.grove
	for road in named_routes:
		if road.name=="junction_to_grove":
			road.controls=PackedVector2Array([landmarks.junction+Vector2(-10,0),landmarks.junction+Vector2(-16,1),Vector2(-25,-31),Vector2(-31,-33),g+Vector2(13,8),g+PARK97.loop_point97(.78)])
			road.points=_smooth(road.controls)
	var loop := PARK97.loop97()
	for i in loop.size(): loop[i]+=g
	named_routes.append({"name":"nature_park97","controls":loop,"points":loop,"radius":1.05})
	_reindex_routes()
	for i in road_endings77.size():
		if Vector2(road_endings77[i].x,road_endings77[i].y).distance_to(g)<6.: road_endings77[i]=Vector4(g.x+9,g.y+7,.6,0.)

func west_front97(z: float) -> float:
	return -18.5+1.2*sin(z*.16)+.8*sin(z*.43)
func height_at(x: float,z: float,enabled: bool) -> float:
	var h := super.height_at(x,z,enabled)
	if not enabled or landmarks.is_empty(): return h
	var p := Vector2(x,z)-Vector2(landmarks.grove)
	if p.x< -15. and p.y> -37. and p.y<23.:
		var edge := west_front97(p.y)
		var wall := 1.-smoothstep(edge-1.4,edge+.6,p.x)
		var extent := smoothstep(-37.,-29.,p.y)*(1.-smoothstep(15.,23.,p.y))
		var crest := 10.6+.7*sin(p.y*.18)+.35*sin(p.x*.45)
		h=maxf(h,lerpf(h,crest,wall*extent))
	var d := ((p-PARK97.DECK)/Vector2(4.,3.4)).length()
	if d<1.25: h=maxf(h,lerpf(2.1,PARK97.DECK_Y,1.-smoothstep(.77,1.15,d)))
	var apron := (1.-smoothstep(2.5,3.6,absf(p.y-PARK97.DECK.y)))*(1.-smoothstep(PARK97.DECK.x-3.5,PARK97.DECK.x-1.5,p.x))*smoothstep(-22.,-20.,p.x)
	h=maxf(h,lerpf(2.1,PARK97.DECK_Y,apron))
	var path_distance := PARK97.path_distance97(p)
	if path_distance<1.15 and not PARK97.on_stairs97(p):
		h=lerpf(h,2.1,1.-smoothstep(.60,1.15,path_distance))
	if absf(p.x-PARK97.STAIR_X)<1.5 and p.y>PARK97.STAIR_TOP-1. and p.y<PARK97.STAIR_FOOT+1.:
		var t := clampf((PARK97.STAIR_FOOT-p.y)/(PARK97.STAIR_FOOT-PARK97.STAIR_TOP),0.,1.)
		var ramp := lerpf(2.1,PARK97.DECK_Y,t)
		var side := 1.-smoothstep(1.3,1.5,absf(p.x-PARK97.STAIR_X))
		h=lerpf(h,ramp,side)
	return h

func is_open_ground(at: Vector2) -> bool:
	var p: Vector2=at-Vector2(landmarks.grove)
	if p.x< -22. and p.y> -32. and p.y<17.:
		return normal_at(at.x,at.y,true).y<.94
	if ((p-PARK97.DECK)/Vector2(5.3,4.7)).length()<1. or PARK97.path_distance97(p)<2.: return true
	return super.is_open_ground(at)
