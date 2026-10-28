extends RefCounted
const TRAIL := [Vector2(0,3),Vector2(-3,2.5),Vector2(-5,1.5),Vector2(-7,.8),Vector2(-9,.9)]
const STONE := Vector2(-10.7,-3.6)
static func trail96(local: Vector2) -> float:
	var d := INF
	for i in TRAIL.size()-1:
		var a: Vector2=TRAIL[i];var ab: Vector2=TRAIL[i+1]-a
		d=minf(d,local.distance_to(a+ab*clampf((local-a).dot(ab)/ab.length_squared(),0.,1.)))
	return 1.-smoothstep(.28,.85,d)
