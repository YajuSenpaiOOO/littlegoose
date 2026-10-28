extends "res://scripts/world/world_surface92.gd"
func height_at(x: float,z: float,enabled: bool) -> float:
	var h := super.height_at(x,z,enabled)
	if not enabled or landmarks.is_empty(): return h
	var p := Vector2(x,z)-Vector2(landmarks.grove)-Vector2(-11,-3.8)
	var d := (p/Vector2(5.8,4.6)).length()
	if d>=1.: return h
	return h+.58*(1.-smoothstep(.25,1.,d))*smoothstep(.95,2.8,route_distance(Vector2(x,z)))
