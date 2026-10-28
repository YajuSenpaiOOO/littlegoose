extends RefCounted
const A := Vector2(12.8,7.9)
const B := Vector2(24.,14.2)
const BANKS := [Vector4(14.,14.,4.1,2.8),Vector4(22.,8.1,3.7,3.2)]
const HEIGHTS := [.50,.62]
static func corridor103(p: Vector2) -> Vector2:
 var ab := B-A;var t := clampf((p-A).dot(ab)/ab.length_squared(),0.,1.)
 return Vector2(p.distance_to(A+ab*t),t)
static func lift103(p: Vector2) -> float:
 var result := 0.
 for i in BANKS.size():
  var bank: Vector4=BANKS[i]
  var d := ((p-Vector2(bank.x,bank.y))/Vector2(bank.z,bank.w)).length()
  if d<1.: result+=float(HEIGHTS[i])*(1.-smoothstep(0.,1.,d))
 return result
