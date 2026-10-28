extends RefCounted
const CENTER := Vector2(-23.0,-16.0)
const RADII := Vector2(7.0,7.0)
const LEVEL := 10.65
const POINTS := [Vector2(-8.8,-5.0),Vector2(-10.8,-11.8),Vector2(-12.5,-12.4),Vector2(-19.0,-15.4)]
const HEIGHTS := [3.65,6.25,6.25,LEVEL]
static func radius136(p: Vector2) -> float: return ((p-CENTER)/RADII).length()
static func stair136(p: Vector2) -> Vector3:
 var best := Vector3(INF,0.,0.)
 for i in 3:
  var a: Vector2=POINTS[i];var b: Vector2=POINTS[i+1]
  var t := clampf((p-a).dot(b-a)/(b-a).length_squared(),0.,1.)
  var d := p.distance_to(a.lerp(b,t))
  if d<best.x: best=Vector3(d,lerpf(HEIGHTS[i],HEIGHTS[i+1],t),float(i))
 return best
static func clear136(p: Vector2) -> bool: return radius136(p)<1.24 or stair136(p).x<2.05
