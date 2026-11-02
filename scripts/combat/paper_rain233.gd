extends "res://scripts/combat/paper_rain232.gd"
const FLY_SPEED233 := 8.
func launch146(packet: Dictionary,origin: Vector3,target: Vector3,gain := 1.,replay := false) -> void:
 var first=planes149.size();super.launch146(packet,origin,target,gain,replay)
 for i in range(first,planes149.size()):
  var f: Dictionary=planes149[i]
  f.node.position=point150(f,0.);f.node.reset_physics_interpolation()
func point150(f: Dictionary,age: float) -> Vector3:
 if not f.has("rain232"):return super.point150(f,age)
 # A level overhead pass has no arrival brake or exit burst. Centre it on
 # this aircraft's release time; keep every drop at the same height as232.
 var r: Dictionary=f.rain232
 return Vector3(r.over)+Vector3(r.direction)*(age-float(f.release))*FLY_SPEED233
