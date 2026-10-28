extends RefCounted
const CENTER := Vector2(-48.,0.)
const TOP := .2
const BASE := -2.2
const RISE := 2.4
const CELL := .5
const CLEARING := Rect2(-14.,-12.,28.,24.)
const ENTRY := Vector2(33.,-3.)
const COTTAGE := Vector2(-8.,-8.8)
const PATH := [Vector2(33.,-3.),Vector2(28.,-3.),Vector2(23.,3.),Vector2(18.,3.),Vector2(14.,7.),Vector2(10.,8.)]
const FLIGHTS := [Vector2(5.5,8.5),Vector2(13.,16.),Vector2(20.5,23.5)]
static func path_sample(p: Vector2) -> Vector2:
 var distance := INF;var along := 0.;var passed := 0.
 for i in range(1,PATH.size()):
  var q := Geometry2D.get_closest_point_to_segment(p,PATH[i-1],PATH[i]);var d := p.distance_to(q)
  if d<distance: distance=d;along=passed+q.distance_to(PATH[i-1])
  passed+=PATH[i].distance_to(PATH[i-1])
 return Vector2(distance,along)
static func path_point(along: float) -> Vector2:
 for i in range(1,PATH.size()):
  var length: float=PATH[i].distance_to(PATH[i-1])
  if along<=length: return PATH[i-1].lerp(PATH[i],along/length)
  along-=length
 return PATH[-1]
static func path_y(along: float,steps := false) -> float:
 var result := TOP
 for flight in FLIGHTS:
  var t := clampf((along-flight.x)/(flight.y-flight.x),0.,1.)
  if steps and t<1.: t=floorf(t*6.)/6.
  result-=.8*t
 return result
static func inside(p: Vector2) -> bool: return Rect2(-24.,-27.,66.,67.).has_point(p)
static func height(p: Vector2) -> float:
 var edge := maxf(absf(p.x)-(14.+.4*sin(p.y*.55)),absf(p.y)-(12.+.4*sin(p.x*.4)))
 var result := lerpf(BASE,TOP,smoothstep(-.65,.25,edge))
 # Preserve the north's original altitude, with a return ramp on the east.
 if p.x>=10. and p.x<=14. and p.y< -4.: result=maxf(result,BASE+RISE*clampf((-p.y-4.)/8.,0.,1.))
 var sample := path_sample(p)
 if p.x>=11. and p.y> -7.: result=lerpf(path_y(sample.y),result,smoothstep(1.8,3.0,sample.x))
 return result
static func visible_height(p: Vector2) -> float:
 var sample := path_sample(p)
 return path_y(sample.y,true) if p.x>12. and sample.x<1.75 else height(p)
static func in_flight(p: Vector2) -> bool:
 var sample := path_sample(p)
 if sample.x>1.75: return false
 for flight in FLIGHTS:
  if sample.y>flight.x and sample.y<flight.y: return true
 return false
static func path_length() -> float: return 27.5902094841
