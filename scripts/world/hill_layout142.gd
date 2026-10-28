extends RefCounted
const VIEW := Vector2(-25.7,-28.3)
const PATH := [Vector2(-19.,-15.4),Vector2(-23.,-19.5),Vector2(-23.8,-24.),VIEW]
const GROVES := [Vector3(-13.8,-29.4,5.0),Vector3(-11.9,-27.0,5.5),Vector3(-15.5,-31.2,4.5)]
static func path_distance(p: Vector2) -> float:
 var distance := INF
 for i in PATH.size()-1:
  var a: Vector2=PATH[i];var b: Vector2=PATH[i+1]
  var t := clampf((p-a).dot(b-a)/(b-a).length_squared(),0.,1.)
  distance=minf(distance,p.distance_to(a.lerp(b,t)))
 return distance
static func view_radius(p: Vector2) -> float: return ((p-VIEW)/Vector2(3.0,2.1)).length()
static func west_radius(p: Vector2) -> float: return ((p-Vector2(-31.0,-9.5))/Vector2(3.1,4.2)).length()
