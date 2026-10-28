extends "res://scripts/world/world_surface136.gd"
func height_at(x: float,z: float,enabled: bool) -> float:
 var h := super.height_at(x,z,enabled)
 if not enabled or landmarks.is_empty(): return h
 var p := Vector2(x,z)-Vector2(landmarks.grove)
 if p.x< -34.5 or p.x> -6. or p.y< -25.5 or p.y> -2.5: return h
 # Add land only inside the existing terrain mesh; never lower old mountains,
 # expand global bounds, change the chunk origin or clip a terrain material.
 var meadow_edge := (((p-Vector2(-24.5,-16.))/Vector2(8.5,8.)).length()-1.)*8.
 var nose_edge := (((p-Vector2(-30.,-17.))/Vector2(3.3,4.8)).length()-1.)*3.3
 var edge := minf(meadow_edge,nose_edge)
 if edge<.85:
  var top := 10.65+.06*sin(p.x*.4)*sin(p.y*.37)
  h=maxf(h,lerpf(h,top,1.-smoothstep(-.16,.85,edge)))
 var stair := HILL136.stair136(p)
 # Keep the already-authored stair corridor smooth where the larger meadow
 # meets its upper flight; plateau fill must not steepen the walking ramp.
 if stair.x<2.05: h=lerpf(h,stair.y-.02,1.-smoothstep(1.43,2.05,stair.x))
 return h
