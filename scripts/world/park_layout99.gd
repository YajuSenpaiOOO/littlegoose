extends RefCounted
const SCALE := .85
const DECK := Vector2(-8.2,-4.2)
const SWING := Vector2(7.85,-4.7)
const BENCH := Vector2(9.2,8.9)
const LOG := Vector2(-5.4,7.3)
const STAIR_X := -7.8
const STAIR_FOOT := 1.25
const STAIR_TOP := -3.1
const DECK_Y := 3.65
const STAIR_YAW := -.28
static func from_stair99(p: Vector2) -> Vector2:
	var pivot := Vector2(STAIR_X,STAIR_FOOT)
	return pivot+(p-pivot).rotated(STAIR_YAW)
static func to_stair99(p: Vector2) -> Vector2:
	var pivot := Vector2(STAIR_X,STAIR_FOOT)
	return pivot+(p-pivot).rotated(-STAIR_YAW)
# Authored bends, with a narrower rear footpath and a wide worn entrance.
const KNOTS := [Vector2(6.8,-.2),Vector2(6.2,2.7),Vector2(5.7,5.7),Vector2(1.1,6.7),Vector2(-2.3,5.2),Vector2(-5.,5.1),Vector2(-5.8,1.9),Vector2(-5.4,-1.5),Vector2(-3.7,-4.7),Vector2(.1,-6.3),Vector2(4.2,-5.8),Vector2(6.5,-3.5)]
const WEAR := [1.,1.,.7,.03,.03,.75,1.,.9,.45,.02,.1,.9]
const WIDTHS := [1.05,1.25,1.1,.82,.72,.9,1.1,.78,.68,.64,.75,.95]
static var points99 := PackedVector2Array()
static var widths99 := PackedFloat32Array()
static var wear99 := PackedFloat32Array()
static var segments99: Array=[]
static var bins99: Dictionary={}
static func build99() -> void:
	if not points99.is_empty(): return
	for i in KNOTS.size():
		var a: Vector2=KNOTS[posmod(i-1,KNOTS.size())];var b: Vector2=KNOTS[i]
		var c: Vector2=KNOTS[(i+1)%KNOTS.size()];var d: Vector2=KNOTS[(i+2)%KNOTS.size()]
		for j in 5:
			var t := float(j)/5.
			points99.append(.5*((2.*b)+(-a+c)*t+(2.*a-5.*b+4.*c-d)*t*t+(-a+3.*b-3.*c+d)*t*t*t))
			widths99.append(lerpf(WIDTHS[i],WIDTHS[(i+1)%WIDTHS.size()],t))
			wear99.append(lerpf(WEAR[i],WEAR[(i+1)%WEAR.size()],t))
	points99.append(points99[0]);widths99.append(widths99[0]);wear99.append(wear99[0])
	for i in points99.size()-1: add_segment99(points99[i],points99[i+1],widths99[i],widths99[i+1],wear99[i],wear99[i+1])
	add_segment99(Vector2(-5.8,1.9),Vector2(STAIR_X,STAIR_FOOT),1.1,1.0)
	add_segment99(Vector2(6.5,-3.5),SWING,.85,1.15)
	add_segment99(Vector2(6.2,2.7),Vector2(13.,8.),1.3,1.2)
	add_segment99(Vector2(-2.3,5.2),Vector2(-4.4,8.2),.65,.75)
static func add_segment99(a: Vector2,b: Vector2,wa: float,wb: float,paint_a := 1.,paint_b := 1.) -> void:
	var index := segments99.size();segments99.append([a,b,wa,wb,paint_a,paint_b])
	var bounds := Rect2(a,Vector2.ZERO).expand(b).grow(4.)
	for x in range(floori(bounds.position.x/4.),ceili(bounds.end.x/4.)+1):
		for y in range(floori(bounds.position.y/4.),ceili(bounds.end.y/4.)+1):
			var key := Vector2i(x,y)
			if not bins99.has(key): bins99[key]=[]
			bins99[key].append(index)
static func info99(p: Vector2) -> Vector3:
	build99()
	var indices: Array=bins99.get(Vector2i(floori(p.x/4.),floori(p.y/4.)),[])
	var best := Vector3(8.,1.,0.)
	for i in indices:
		var s: Array=segments99[i];var ab: Vector2=s[1]-s[0]
		var t := clampf((p-s[0]).dot(ab)/ab.length_squared(),0.,1.)
		var distance := p.distance_to(s[0]+ab*t);var width := lerpf(s[2],s[3],t)
		if distance/width<best.x/best.y: best=Vector3(distance,width,lerpf(s[4],s[5],t))
	return best
static func path_distance99(p: Vector2) -> float:
	var info := info99(p);return info.x/info.y
static func loop99() -> PackedVector2Array:
	build99();return points99.duplicate()
static func loop_point99(angle: float) -> Vector2:
	build99();var t := fposmod(angle/TAU,1.)*(points99.size()-1)
	return points99[floori(t)].lerp(points99[floori(t)+1],fposmod(t,1.))
static func on_stairs99(p: Vector2) -> bool:
	var local := to_stair99(p)
	return absf(local.x-STAIR_X)<1.35 and local.y>=STAIR_TOP-.2 and local.y<=STAIR_FOOT+.2
