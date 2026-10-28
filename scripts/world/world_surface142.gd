extends "res://scripts/world/world_surface140.gd"
const PLAN142=preload("res://scripts/world/hill_layout142.gd")
func height_at(x: float,z: float,enabled: bool) -> float:
 var h := super.height_at(x,z,enabled)
 if not enabled or landmarks.is_empty(): return h
 var p := Vector2(x,z)-Vector2(landmarks.grove)
 if p.x< -35. or p.x> -8. or p.y< -35. or p.y> -4.: return h
 # Rock shoulder fills the south-west hollow. No tree is used as a plug.
 var west := PLAN142.west_radius(p)
 if west<1.1: h=maxf(h,lerpf(h,13.6,1.-smoothstep(.10,1.1,west)))
 # A separate eastern rock shoulder; trees belong on the flat bench behind it.
 var rock := ((p-Vector2(-17.4,-22.2))/Vector2(3.0,4.0)).length()
 if rock<1.: h+=2.5*pow(1.-rock*rock,2.)
 var bench := ((p-Vector2(-13.5,-29.5))/Vector2(4.0,4.1)).length()
 if bench<1.3: h=lerpf(h,11.15,1.-smoothstep(.92,1.3,bench))
 # The lookout follows the original 140 land; no isolated raised stone disk.
 return h
