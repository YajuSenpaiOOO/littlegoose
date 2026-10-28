extends "res://scripts/world/world_surface107.gd"
const HILL137=preload("res://scripts/world/park_layout137.gd")
func _init() -> void:
 super._init()
 world_bounds.position.x-=24.;world_bounds.size.x+=24.
 var points := PackedVector2Array()
 for p in HILL137.POINTS: points.append(landmarks.grove+p)
 named_routes.append({"name":"paper_hill137","controls":points,"points":points,"radius":1.15})
 _reindex_routes()
func height_at(x: float,z: float,enabled: bool) -> float:
 var h := super.height_at(x,z,enabled)
 if not enabled or landmarks.is_empty(): return h
 var p := Vector2(x,z)-Vector2(landmarks.grove)
 if p.x> -5. or p.y>20.: return h
 var sea := (1.-smoothstep(-20.,-12.,p.x))*(1.-smoothstep(5.,18.,p.y))
 h=lerpf(h,-25.,sea)
 var edge := HILL137.edge137(p)
 var envelope := 1.-smoothstep(4.,9.,edge)
 # A usable gently graded top, a small rounded lip and a real steep rock face.
 var swell := .13*sin(p.x*.26)*sin(p.y*.32)+.06*cos(p.y*.57)
 var crown := HILL137.LEVEL+swell+.12*exp(-pow((edge+.7)/.8,2.))
 var headland := lerpf(crown,-25.,smoothstep(-.10,1.65,edge))
 h=lerpf(h,headland,envelope)
 var stair := HILL137.stair137(p)
 var corridor := 1.-smoothstep(1.48,2.55,stair.x)
 return lerpf(h,stair.y,corridor)
func is_open_ground(at: Vector2) -> bool:
 if not landmarks.is_empty() and height_at(at.x,at.y,true)<-6.: return true
 if not landmarks.is_empty() and HILL137.clear137(at-Vector2(landmarks.grove)): return true
 return super.is_open_ground(at)
func _terrain_divisions19(rect: Rect2,ids: Array[int]) -> int:
 var patch := Rect2(Vector2(landmarks.grove)+Vector2(-53,-36),Vector2(48,39))
 return 72 if rect.intersects(patch) else super._terrain_divisions19(rect,ids)
