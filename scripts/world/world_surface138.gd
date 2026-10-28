extends "res://scripts/world/world_surface107.gd"
const HILL138=preload("res://scripts/world/park_layout137.gd")
var original_bounds138 := Rect2()
func _init() -> void:
 super._init()
 original_bounds138=world_bounds
 world_bounds.position.x-=24.;world_bounds.size.x+=24.
 var points := PackedVector2Array()
 for p in HILL138.POINTS: points.append(landmarks.grove+p)
 named_routes.append({"name":"paper_hill138","controls":points,"points":points,"radius":1.15})
 _reindex_routes()
func height_at(x: float,z: float,enabled: bool) -> float:
 var inherited := super.height_at(x,z,enabled)
 if not enabled or landmarks.is_empty(): return inherited
 var p := Vector2(x,z)-Vector2(landmarks.grove)
 var h := inherited
 # Only the ADDED western geography can be lowered into the coastal backdrop.
 # Existing land, including the northern mountain behind the stairs, stays solid.
 if x<original_bounds138.position.x:
  var edge := HILL138.edge137(p)
  var crown := HILL138.LEVEL+.10*sin(p.x*.26)*sin(p.y*.32)
  var extension := lerpf(crown,-40.,smoothstep(-.12,1.7,edge))
  h=lerpf(inherited,extension,smoothstep(0.,1.6,original_bounds138.position.x-x))
 # Grade only the small central play space upward; never excavate old shelves.
 var center := ((p-HILL138.CENTER)/Vector2(6.0,5.0)).length()
 if center<1.2:
  var crown := HILL138.LEVEL+.10*sin(p.x*.26)*sin(p.y*.32)
  h=lerpf(h,maxf(h,crown),1.-smoothstep(.85,1.2,center))
 var stair := HILL138.stair137(p)
 if stair.x<2.25: h=lerpf(h,stair.y,1.-smoothstep(1.48,2.25,stair.x))
 return h
func is_open_ground(at: Vector2) -> bool:
 if not landmarks.is_empty():
  var p: Vector2=at-Vector2(landmarks.grove)
  if HILL138.stair137(p).x<1.85: return true
  if ((p-HILL138.CENTER)/Vector2(4.8,4.2)).length()<1.: return true
  if at.x<original_bounds138.position.x: return true
 return super.is_open_ground(at)
func _terrain_divisions19(rect: Rect2,ids: Array[int]) -> int:
 var patch := Rect2(Vector2(landmarks.grove)+Vector2(-53,-32),Vector2(48,34))
 return 72 if rect.intersects(patch) else super._terrain_divisions19(rect,ids)
