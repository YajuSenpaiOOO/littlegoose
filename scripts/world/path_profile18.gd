extends RefCounted
## Reusable cross section; distances are in world metres, independent of a map.
var enabled := true
var depth := .11
func depression(distance_to_path: float,distance_from_entry: float=100.) -> float:
	if not enabled: return 0.
	return depth*(1.-smoothstep(.60,.98,distance_to_path))*smoothstep(.75,2.2,distance_from_entry)
