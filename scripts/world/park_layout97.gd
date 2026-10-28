extends RefCounted
const SCALE := .85
const DECK := Vector2(-11.05,-4.59)
const SWING := Vector2(11.05,-5.1)
const BENCH := Vector2(9.35,7.65)
const LOG := Vector2(-6.8,10.2)
const STAIR_X := -10.625
const STAIR_FOOT := 1.7
const STAIR_TOP := -2.55
const DECK_Y := 4.35
static func loop_point97(angle: float) -> Vector2:
	return Vector2(1.15+9.9*cos(angle)+.51*sin(3.*angle),8.5*sin(angle)+.51*sin(2.*angle))
static func loop97() -> PackedVector2Array:
	var points := PackedVector2Array()
	for i in 41: points.append(loop_point97(TAU*float(i)/40.))
	return points
static func segment97(p: Vector2,a: Vector2,b: Vector2) -> float:
	return p.distance_to(Geometry2D.get_closest_point_to_segment(p,a,b))
static func path_distance97(p: Vector2) -> float:
	var angle := atan2(p.y/8.5,(p.x-1.15)/9.9)
	var d := p.distance_to(loop_point97(angle))
	d=minf(d,segment97(p,Vector2(-8.7,1.7),Vector2(STAIR_X,STAIR_FOOT)))
	d=minf(d,segment97(p,Vector2(12,-7)*SCALE,SWING))
	return d
static func on_stairs97(p: Vector2) -> bool:
	return absf(p.x-STAIR_X)<1.35 and p.y>=STAIR_TOP-.2 and p.y<=STAIR_FOOT+.2
