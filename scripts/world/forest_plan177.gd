extends RefCounted
## World coordinates match the surveyed southwest site. This plan is instantiated
## only by the independent sandbox, never by the existing world scenes.
const CENTER := Vector2(-48.,0.)
const BASE := .2
const RISE := 2.4
const CELL := .5
const CLEARING := Rect2(-14.,-12.,28.,24.)
const TERRACE := Rect2(-17.,-19.,34.,7.)
const ENTRY := Vector2(33.,-3.)
const TRUNK := Vector2(-1.,0.)
const COTTAGE := Vector2(-8.,-8.8)
const PATH := [Vector2(33.,-3.),Vector2(28.,-3.),Vector2(23.,3.),Vector2(18.,3.),Vector2(14.,7.),Vector2(10.,8.)]
static func path_distance(p: Vector2) -> float:
 var result := INF
 for i in range(1,PATH.size()): result=minf(result,Geometry2D.get_closest_point_to_segment(p,PATH[i-1],PATH[i]).distance_to(p))
 return result
static func inside(p: Vector2) -> bool:
 return CLEARING.has_point(p) or TERRACE.has_point(p) or path_distance(p)<1.9
static func height(p: Vector2) -> float:
 if p.y<=-12.: return BASE+RISE
 if p.x>=10. and p.x<=14. and p.y< -4.: return BASE+RISE*clampf((-p.y-4.)/8.,0.,1.)
 return BASE
static func path_length() -> float:
 var total := 0.
 for i in range(1,PATH.size()): total+=PATH[i-1].distance_to(PATH[i])
 return total
