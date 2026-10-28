extends RefCounted
const CENTER := Vector2(-27.,-16.)
const LEVEL := 10.65
const POINTS := [Vector2(-8.8,-5.),Vector2(-10.8,-11.8),Vector2(-12.5,-12.4),Vector2(-19.,-15.4)]
const HEIGHTS := [3.65,6.25,6.25,LEVEL]
static func edge137(p: Vector2) -> float:
 # Two overlapping, gently irregular landforms form a broad meadow and a
 # westward rocky nose. The signed edge is independent of the mesh bounds.
 var q := (p-CENTER)/Vector2(11.2,9.8)
 var angle := atan2(q.y,q.x)
 var a := (q.length()-1.-.06*sin(angle*3.+.4)-.035*sin(angle*5.))*9.8
 var b := (((p-Vector2(-37.,-18.5))/Vector2(7.0,5.6)).length()-1.)*5.6
 var blend := maxf(.9-absf(a-b),0.)/.9
 return minf(a,b)-blend*blend*.225
static func stair137(p: Vector2) -> Vector3:
 return preload("res://scripts/world/park_layout136.gd").stair136(p)
static func clear137(p: Vector2) -> bool: return edge137(p)<2.1 or stair137(p).x<2.3
