extends RefCounted
const CENTER := Vector2(-24.0,-18.0)
const RADII := Vector2(9.2,12.8)
static func radius140(p: Vector2) -> float:
 var q := (p-CENTER)/RADII
 var angle := q.angle()
 return q.length()/(1.+.025*sin(angle*3.)+.018*cos(angle*5.))
static func rim140(angle: float) -> Vector2:
 return CENTER+Vector2(cos(angle),sin(angle))*RADII*.92*(1.+.025*sin(angle*3.)+.018*cos(angle*5.))
static func level140(p: Vector2) -> float:
 var back := ((p-Vector2(-23.5,-27.5))/Vector2(6.7,4.5)).length()
 var lookout := ((p-Vector2(-30.5,-17.))/Vector2(3.,5.)).length()
 var front := ((p-Vector2(-23.,-8.5))/Vector2(6.,3.5)).length()
 return 10.65+.85*(1.-smoothstep(.1,1.1,back))+.48*(1.-smoothstep(.05,1.2,lookout))-.18*(1.-smoothstep(.1,1.,front))+.045*sin(p.x*.5)*sin(p.y*.4)
