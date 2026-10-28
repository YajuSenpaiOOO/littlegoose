extends "res://scripts/world/world_surface139.gd"
const HILL140=preload("res://scripts/world/park_layout140.gd")
func height_at(x: float,z: float,enabled: bool) -> float:
 var original := super.height_at(x,z,enabled)
 if not enabled or landmarks.is_empty(): return original
 var p := Vector2(x,z)-Vector2(landmarks.grove)
 if p.x< -34.2 or p.x> -13.3 or p.y< -33. or p.y> -3.5: return original
 var radius := HILL140.radius140(p)
 var h := maxf(original,lerpf(original,HILL140.level140(p),1.-smoothstep(.91,1.10,radius)))
 # Preserve 139's verified stair gradient independently of the larger meadow.
 var stair := HILL136.stair136(p)
 if stair.x<2.05: h=lerpf(h,stair.y-.02,1.-smoothstep(1.43,2.05,stair.x))
 return h
func is_open_ground(at: Vector2) -> bool:
 if not landmarks.is_empty() and HILL140.radius140(at-Vector2(landmarks.grove))<1.04: return true
 return super.is_open_ground(at)
func _terrain_divisions19(rect: Rect2,ids: Array[int]) -> int:
 var hill := Rect2(Vector2(landmarks.grove)+Vector2(-35,-34),Vector2(22,31))
 return 64 if rect.intersects(hill) else super._terrain_divisions19(rect,ids)
