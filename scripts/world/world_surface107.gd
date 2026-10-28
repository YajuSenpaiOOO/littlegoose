extends "res://scripts/world/world_surface103.gd"
const KNOLLS107=[Vector4(-3.3,-2.9,2.2,1.8),Vector4(3.2,-3.9,2.2,1.8)]
static func lift107(p: Vector2) -> float:
 var lift := 0.
 for i in KNOLLS107.size():
  var spec: Vector4=KNOLLS107[i]
  var d := ((p-Vector2(spec.x,spec.y))/Vector2(spec.z,spec.w)).length()
  if d<1.: lift+=(.34 if i==0 else .40)*pow(1.-d*d,2.)
 return lift
func height_at(x: float,z: float,enabled: bool) -> float:
 var height := super.height_at(x,z,enabled)
 if not enabled or landmarks.is_empty(): return height
 var p := Vector2(x,z)-Vector2(landmarks.grove)
 if absf(p.x)>5.6 or p.y< -5.8 or p.y> -1.: return height
 return height+lift107(p)
