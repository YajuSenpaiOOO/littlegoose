extends "res://scripts/world/world_surface140.gd"
const VIEW141 := Vector2(-25.7,-28.3)
func height_at(x: float,z: float,enabled: bool) -> float:
 var h := super.height_at(x,z,enabled)
 if not enabled or landmarks.is_empty(): return h
 var p := Vector2(x,z)-Vector2(landmarks.grove)
 # Confine new silhouettes to the east/north edge, clear of the verified stairs.
 if p.x< -32.5 or p.x> -12. or p.y< -32. or p.y> -17.5: return h
 for mound in [Vector4(-16.6,-23.,3.0,4.7),Vector4(-19.3,-28.,3.0,2.8)]:
  var r := ((p-Vector2(mound.x,mound.y))/Vector2(mound.z,mound.w)).length()
  if r<1.: h+=3.0*pow(1.-r*r,2.)
 var view_radius := ((p-VIEW141)/Vector2(3.3,3.0)).length()
 h=lerpf(h,maxf(h,12.55+.055*sin(p.x*1.3)*sin(p.y*.9)),1.-smoothstep(.50,1.25,view_radius))
 return h
