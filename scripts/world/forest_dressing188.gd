extends RefCounted
const PLAN=preload("res://scripts/world/forest_plan188.gd")
const TRAIL := [Vector2(10.,8.),Vector2(6.,6.5),Vector2(3.,4.),Vector2(-4.5,3.5),Vector2(-6.,1.),Vector2(-5.6,-3.5),Vector2(-6.3,-5.2),Vector2(-8.,-7.),Vector2(-10.4,-8.1)]
static func distance188(p: Vector2) -> float:
 var result := PLAN.path_sample(p).x if p.x>9. else INF
 for i in range(1,TRAIL.size()): result=minf(result,Geometry2D.get_closest_point_to_segment(p,TRAIL[i-1],TRAIL[i]).distance_to(p))
 return result
