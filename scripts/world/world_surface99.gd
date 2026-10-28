extends "res://scripts/world/world_surface96.gd"
const PARK99=preload("res://scripts/world/park_layout99.gd")
func _init() -> void:
	super._init()
	var g: Vector2=landmarks.grove
	for road in named_routes:
		if road.name=="junction_to_grove":
			road.controls=PackedVector2Array([landmarks.junction+Vector2(-10,0),landmarks.junction+Vector2(-16,1),Vector2(-25,-31),Vector2(-31,-33),g+Vector2(13,8),g+PARK99.loop_point99(.78)])
			road.points=_smooth(road.controls)
	var loop := PARK99.loop99()
	for i in loop.size(): loop[i]+=g
	named_routes.append({"name":"nature_park99","controls":loop,"points":loop,"radius":1.05})
	_reindex_routes()
	for i in road_endings77.size():
		if Vector2(road_endings77[i].x,road_endings77[i].y).distance_to(g)<6.: road_endings77[i]=Vector4(g.x+9,g.y+7,.6,0.)

func west_front99(z: float) -> float:
	return -14.8+1.0*sin(z*.16)+.6*sin(z*.43)
func height_at(x: float,z: float,enabled: bool) -> float:
	var h := super.height_at(x,z,enabled)
	if not enabled or landmarks.is_empty(): return h
	var p := Vector2(x,z)-Vector2(landmarks.grove)
	if p.x< -11. and p.y> -37. and p.y<23.:
		var edge := west_front99(p.y)
		var wall := 1.-smoothstep(edge-1.4,edge+.6,p.x)
		var extent := smoothstep(-37.,-29.,p.y)*(1.-smoothstep(15.,23.,p.y))
		var crest := 10.6+.7*sin(p.y*.18)+.35*sin(p.x*.45)
		h=maxf(h,lerpf(h,crest,wall*extent))
	var d := ((p-PARK99.DECK)/Vector2(4.,3.4)).length()
	if d<1.25: h=maxf(h,lerpf(2.1,PARK99.DECK_Y,1.-smoothstep(.77,1.15,d)))
	var apron := (1.-smoothstep(2.5,3.6,absf(p.y-PARK99.DECK.y)))*(1.-smoothstep(PARK99.DECK.x-3.5,PARK99.DECK.x-1.5,p.x))*smoothstep(-22.,-20.,p.x)
	# A zero apron weight must leave the inherited terrain untouched. Applying
	# max(h, 2.1) here raised the entire world's lower terraces and lake bed.
	if apron>0.: h=maxf(h,lerpf(2.1,PARK99.DECK_Y,apron))
	# The mountain's low shoulder wraps the rear half of the lookout.
	var shoulder := ((p-Vector2(-12.8,-8.3))/Vector2(6.6,5.5)).length()
	if shoulder<1.15:
		h=maxf(h,lerpf(2.1,7.1,1.-smoothstep(.25,1.15,shoulder)))
	var path_distance := PARK99.path_distance99(p)
	if path_distance<1.15 and not PARK99.on_stairs99(p):
		h=lerpf(h,2.1,1.-smoothstep(.60,1.15,path_distance))
	var stair := PARK99.to_stair99(p)
	if absf(stair.x-PARK99.STAIR_X)<1.5 and stair.y>PARK99.STAIR_TOP-1. and stair.y<PARK99.STAIR_FOOT+1.:
		var t := clampf((PARK99.STAIR_FOOT-stair.y)/(PARK99.STAIR_FOOT-PARK99.STAIR_TOP),0.,1.)
		var ramp := lerpf(2.1,PARK99.DECK_Y,t)
		var side := 1.-smoothstep(1.3,1.5,absf(stair.x-PARK99.STAIR_X))
		h=lerpf(h,ramp,side)
	return h

func is_open_ground(at: Vector2) -> bool:
	var p: Vector2=at-Vector2(landmarks.grove)
	if p.x< -22. and p.y> -32. and p.y<17.:
		return normal_at(at.x,at.y,true).y<.94
	if ((p-PARK99.DECK)/Vector2(5.3,4.7)).length()<1. or PARK99.path_distance99(p)<2.: return true
	return super.is_open_ground(at)
