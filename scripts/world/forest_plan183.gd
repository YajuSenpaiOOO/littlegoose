extends "res://scripts/world/forest_plan179.gd"
static func ellipse183(p: Vector2,center: Vector2,radii: Vector2) -> float:
 return ((p-center)/radii).length()*minf(radii.x,radii.y)-minf(radii.x,radii.y)
static func edge183(p: Vector2) -> float:
 # Unequal overlapping coves rather than a rounded rectangle. Subtracted rock
 # shoulders form a west pinch and a scalloped northern rear wall.
 var d := minf(ellipse183(p,Vector2(-1.,0.),Vector2(14.,10.5)),ellipse183(p,Vector2(-8.,-5.5),Vector2(7.,5.5)))
 d=minf(d,ellipse183(p,Vector2(6.,5.3),Vector2(8.5,6.5)))
 d=minf(d,ellipse183(p,Vector2(5.,-5.8),Vector2(7.,5.2)))
 d=minf(d,ellipse183(p,Vector2(-11.,-11.),Vector2(5.5,4.8)))
 d=maxf(d,-((p-Vector2(-4.8,-10.)).length()-3.))
 d=maxf(d,-((p-Vector2(-16.,-6.)).length()-2.6))
 d=maxf(d,-((p-Vector2(-14.,.5)).length()-3.3))
 d=maxf(d,-((p-Vector2(-1.,-11.5)).length()-2.8))
 return d+.16*sin(p.x*1.25+p.y*.85)
static func affects183(at: Vector2) -> bool:
 if not Rect2(-67.,-18.,55.,33.).has_point(at): return false
 var p := at-CENTER
 return edge183(p)<1.6 or (p.x>10. and p.x<35. and path_sample(p).x<3.4)
static func tree_clear183(at: Vector2) -> bool:
 if not Rect2(-67.,-18.,60.,34.).has_point(at): return false
 var p := at-CENTER
 return edge183(p)<1.1 or (p.x>10. and path_sample(p).x<3.) or Geometry2D.get_closest_point_to_segment(at,Vector2(-6.8,.5),CENTER+ENTRY).distance_to(at)<2.
static func height183(p: Vector2) -> float:
 var result := lerpf(BASE,TOP,smoothstep(-.5,.55,edge183(p)))
 if p.x>10. and p.x<14. and p.y< -4. and p.y> -14.: result=maxf(result,BASE+RISE*clampf((-p.y-4.)/8.,0.,1.))
 var sample := path_sample(p)
 if p.x>10. and p.y> -7.: result=lerpf(path_y(sample.y),result,smoothstep(1.8,3.,sample.x))
 return result
static func visible183(p: Vector2) -> float:
 var sample := path_sample(p)
 return path_y(sample.y,true) if p.x>12. and sample.x<1.75 else height183(p)
