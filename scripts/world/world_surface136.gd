extends "res://scripts/world/world_surface107.gd"
const HILL136=preload("res://scripts/world/park_layout136.gd")
func _init() -> void:
 super._init()
 var points := PackedVector2Array()
 for p in HILL136.POINTS: points.append(landmarks.grove+p)
 named_routes.append({"name":"paper_hill136","controls":points,"points":points,"radius":1.0})
 _reindex_routes()
func height_at(x: float,z: float,enabled: bool) -> float:
 var h := super.height_at(x,z,enabled)
 if not enabled or landmarks.is_empty(): return h
 var p := Vector2(x,z)-Vector2(landmarks.grove)
 if p.x> -6.2 or p.x< -45. or p.y> -2.5 or p.y< -27.: return h
 var radial := HILL136.radius136(p)
 var weight := 1.-smoothstep(.88,1.30,radial)
 var crown := HILL136.LEVEL+.045*sin(p.x*.8)*sin(p.y*.6)
 h=lerpf(h,crown,weight)
 # Open a local western cliff face; other forest shelves stay untouched.
 var west := (1.-smoothstep(-32.2,-30.5,p.x))*smoothstep(-27.,-23.,p.y)*(1.-smoothstep(-8.,-3.,p.y))
 h=lerpf(h,1.7,west)
 var stair := HILL136.stair136(p)
 var corridor := 1.-smoothstep(1.10,2.35,stair.x)
 return lerpf(h,stair.y-.10,corridor)
func is_open_ground(at: Vector2) -> bool:
 if not landmarks.is_empty() and HILL136.clear136(at-Vector2(landmarks.grove)): return true
 return super.is_open_ground(at)
func _terrain_divisions19(rect: Rect2,ids: Array[int]) -> int:
 var hill := Rect2(Vector2(landmarks.grove)+Vector2(-40,-27),Vector2(35,26))
 return 64 if rect.intersects(hill) else super._terrain_divisions19(rect,ids)
