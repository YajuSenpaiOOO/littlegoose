extends "res://scripts/world/forest_plan179.gd"
static func ellipse180(p: Vector2,center: Vector2,radii: Vector2) -> float:
 return ((p-center)/radii).length()*minf(radii.x,radii.y)-minf(radii.x,radii.y)
static func edge180(p: Vector2) -> float:
 # Unequal overlapping coves rather than a rounded rectangle. Subtracted rock
 # shoulders form a west pinch and a scalloped northern rear wall.
 var d := minf(ellipse180(p,Vector2(-1.,0.),Vector2(14.,10.5)),ellipse180(p,Vector2(-8.,-5.5),Vector2(7.,5.5)))
 d=minf(d,ellipse180(p,Vector2(6.,5.3),Vector2(8.5,6.5)))
 d=minf(d,ellipse180(p,Vector2(5.,-5.8),Vector2(7.,5.2)))
 d=maxf(d,-((p-Vector2(-14.,.5)).length()-3.3))
 d=maxf(d,-((p-Vector2(-1.,-11.5)).length()-2.8))
 return d+.16*sin(p.x*1.25+p.y*.85)
static func affects180(at: Vector2) -> bool:
 if not Rect2(-66.,-14.,54.,28.).has_point(at): return false
 var p := at-CENTER
 return edge180(p)<1.6 or (p.x>10. and p.x<35. and path_sample(p).x<3.4)
static func tree_clear180(at: Vector2) -> bool:
 if not Rect2(-66.,-14.,59.,29.).has_point(at): return false
 var p := at-CENTER
 return edge180(p)<1.1 or (p.x>10. and path_sample(p).x<3.) or Geometry2D.get_closest_point_to_segment(at,Vector2(-6.8,.5),CENTER+ENTRY).distance_to(at)<2.
static func height180(p: Vector2) -> float:
 var result := lerpf(BASE,TOP,smoothstep(-.5,.55,edge180(p)))
 if p.x>10. and p.x<14. and p.y< -4. and p.y> -14.: result=maxf(result,BASE+RISE*clampf((-p.y-4.)/8.,0.,1.))
 var sample := path_sample(p)
 if p.x>10. and p.y> -7.: result=lerpf(path_y(sample.y),result,smoothstep(1.8,3.,sample.x))
 return result
static func visible180(p: Vector2) -> float:
 var sample := path_sample(p)
 return path_y(sample.y,true) if p.x>12. and sample.x<1.75 else height180(p)
