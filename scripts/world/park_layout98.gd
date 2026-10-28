extends RefCounted
const SCALE := .85
const DECK := Vector2(-11.05,-4.59)
const SWING := Vector2(11.05,-5.1)
const BENCH := Vector2(10.5,8.6)
const LOG := Vector2(-6.8,10.2)
const STAIR_X := -10.625
const STAIR_FOOT := 1.7
const STAIR_TOP := -2.55
const DECK_Y := 4.35
const STAIR_YAW := -.22
static func from_stair98(p: Vector2) -> Vector2:
	var pivot := Vector2(STAIR_X,STAIR_FOOT)
	return pivot+(p-pivot).rotated(STAIR_YAW)
static func to_stair98(p: Vector2) -> Vector2:
	var pivot := Vector2(STAIR_X,STAIR_FOOT)
	return pivot+(p-pivot).rotated(-STAIR_YAW)
# Authored bends, with a narrower rear footpath and a wide worn entrance.
const KNOTS := [Vector2(10.,-.8),Vector2(8.6,4.0),Vector2(7.1,8.3),Vector2(1.,9.1),Vector2(-4.7,7.2),Vector2(-8.3,6.4),Vector2(-9.1,2.2),Vector2(-8.,-2.0),Vector2(-5.8,-6.9),Vector2(-.2,-8.9),Vector2(5.8,-7.7),Vector2(9.0,-4.9)]
const WIDTHS := [1.05,1.25,1.1,.82,.72,.9,1.1,.78,.68,.64,.75,.95]
static var points98 := PackedVector2Array()
static var widths98 := PackedFloat32Array()
static var segments98: Array=[]
static var bins98: Dictionary={}
static func build98() -> void:
	if not points98.is_empty(): return
	for i in KNOTS.size():
		var a: Vector2=KNOTS[posmod(i-1,KNOTS.size())];var b: Vector2=KNOTS[i]
		var c: Vector2=KNOTS[(i+1)%KNOTS.size()];var d: Vector2=KNOTS[(i+2)%KNOTS.size()]
		for j in 5:
			var t := float(j)/5.
			points98.append(.5*((2.*b)+(-a+c)*t+(2.*a-5.*b+4.*c-d)*t*t+(-a+3.*b-3.*c+d)*t*t*t))
			widths98.append(lerpf(WIDTHS[i],WIDTHS[(i+1)%WIDTHS.size()],t))
	points98.append(points98[0]);widths98.append(widths98[0])
	for i in points98.size()-1: add_segment98(points98[i],points98[i+1],widths98[i],widths98[i+1])
	add_segment98(Vector2(-9.1,2.2),Vector2(STAIR_X,STAIR_FOOT),1.1,1.0)
	add_segment98(Vector2(9.,-4.9),SWING,.85,1.15)
	add_segment98(Vector2(8.6,4.),Vector2(13.,8.),1.3,1.2)
	add_segment98(Vector2(-4.7,7.2),Vector2(-5.6,10.9),.65,.75)
static func add_segment98(a: Vector2,b: Vector2,wa: float,wb: float) -> void:
	var index := segments98.size();segments98.append([a,b,wa,wb])
	var bounds := Rect2(a,Vector2.ZERO).expand(b).grow(4.)
	for x in range(floori(bounds.position.x/4.),ceili(bounds.end.x/4.)+1):
		for y in range(floori(bounds.position.y/4.),ceili(bounds.end.y/4.)+1):
			var key := Vector2i(x,y)
			if not bins98.has(key): bins98[key]=[]
			bins98[key].append(index)
static func info98(p: Vector2) -> Vector2:
	build98()
	var indices: Array=bins98.get(Vector2i(floori(p.x/4.),floori(p.y/4.)),[])
	var best := Vector2(8.,1.)
	for i in indices:
		var s: Array=segments98[i];var ab: Vector2=s[1]-s[0]
		var t := clampf((p-s[0]).dot(ab)/ab.length_squared(),0.,1.)
		var distance := p.distance_to(s[0]+ab*t);var width := lerpf(s[2],s[3],t)
		if distance/width<best.x/best.y: best=Vector2(distance,width)
	return best
static func path_distance98(p: Vector2) -> float:
	var info := info98(p);return info.x/info.y
static func loop98() -> PackedVector2Array:
	build98();return points98.duplicate()
static func loop_point98(angle: float) -> Vector2:
	build98();var t := fposmod(angle/TAU,1.)*(points98.size()-1)
	return points98[floori(t)].lerp(points98[floori(t)+1],fposmod(t,1.))
static func on_stairs98(p: Vector2) -> bool:
	var local := to_stair98(p)
	return absf(local.x-STAIR_X)<1.35 and local.y>=STAIR_TOP-.2 and local.y<=STAIR_FOOT+.2
