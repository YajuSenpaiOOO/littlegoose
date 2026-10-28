extends RefCounted
## South-moved version of the low forest.  It deliberately keeps the old
## world origin and moves only this authored region.
const CENTER := Vector2(-48.,24.)
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
static func in_flight(p: Vector2) -> bool:
 var sample := path_sample(p)
 if sample.x>1.75: return false
 for flight in FLIGHTS:
  if sample.y>flight.x and sample.y<flight.y: return true
 return false
static func ellipse188(p: Vector2,center: Vector2,radii: Vector2) -> float:
 return ((p-center)/radii).length()*minf(radii.x,radii.y)-minf(radii.x,radii.y)
static func edge188(p: Vector2) -> float:
 var d := minf(ellipse188(p,Vector2(-1.,0.),Vector2(14.,10.5)),ellipse188(p,Vector2(-8.,-5.5),Vector2(7.,5.5)))
 d=minf(d,ellipse188(p,Vector2(6.,5.3),Vector2(8.5,6.5)))
 d=minf(d,ellipse188(p,Vector2(5.,-5.8),Vector2(7.,5.2)))
 d=minf(d,ellipse188(p,Vector2(-11.,-11.),Vector2(5.5,4.8)))
 d=maxf(d,-((p-Vector2(-4.8,-10.)).length()-3.))
 d=maxf(d,-((p-Vector2(-16.,-6.)).length()-2.6))
 d=maxf(d,-((p-Vector2(-14.,.5)).length()-3.3))
 d=maxf(d,-((p-Vector2(-1.,-11.5)).length()-2.8))
 return d+.16*sin(p.x*1.25+p.y*.85)
static func affects188(at: Vector2) -> bool:
 if not Rect2(CENTER+Vector2(-19.,-18.),Vector2(55.,33.)).has_point(at): return false
 var p := at-CENTER
 return edge188(p)<1.6 or (p.x>10. and p.x<35. and path_sample(p).x<3.4)
static func region188(at: Vector2) -> bool:
 return Rect2(CENTER+Vector2(-20.,-19.),Vector2(58.,36.)).has_point(at)
static func tree_clear188(at: Vector2) -> bool:
 if not region188(at): return false
 var p := at-CENTER
 return edge188(p)<1.35 or (p.x>10. and path_sample(p).x<3.2) or Geometry2D.get_closest_point_to_segment(at,CENTER+Vector2(-6.8,.5),CENTER+ENTRY).distance_to(at)<2.
static func height188(p: Vector2) -> float:
 var result := lerpf(BASE,TOP,smoothstep(-.5,.55,edge188(p)))
 if p.x>10. and p.x<14. and p.y< -4. and p.y> -14.: result=maxf(result,BASE+RISE*clampf((-p.y-4.)/8.,0.,1.))
 var sample := path_sample(p)
 if p.x>10. and p.y> -7.: result=lerpf(path_y(sample.y),result,smoothstep(1.8,3.,sample.x))
 return result
static func visible188(p: Vector2) -> float:
 var sample := path_sample(p)
 return path_y(sample.y,true) if p.x>12. and sample.x<1.75 else height188(p)
static func path_length() -> float: return 27.5902094841
