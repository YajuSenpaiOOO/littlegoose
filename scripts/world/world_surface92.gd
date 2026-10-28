extends "res://scripts/world/world_surface90.gd"
## Two low meadow swells share the clearing's land, rather than its perimeter.
func height_at(x: float,z: float,enabled: bool) -> float:
	var h := super.height_at(x,z,enabled)
	if not enabled or landmarks.is_empty(): return h
	var at := Vector2(x,z)
	var local := at-Vector2(landmarks.grove)
	var radius := (local/Vector2(20.,15.)).length()
	if radius>1.16: return h
	var left := ((local-Vector2(-12.,7.))/Vector2(5.8,4.3)).length_squared()
	var right := ((local-Vector2(10.,-6.))/Vector2(5.4,4.8)).length_squared()
	var swell := .43*exp(-left*.85)+.37*exp(-right*.85)
	var road := smoothstep(.95,2.8,route_distance(at))
	return h+swell*road*(1.-smoothstep(.85,1.16,radius))
