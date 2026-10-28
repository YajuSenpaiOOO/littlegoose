extends "res://scripts/world/world_surface21.gd"
const LOOKOUT := Vector2(-12.,-5.2)

func _init() -> void:
	super._init()
	var controls := PackedVector2Array([Vector2(-6.,-1.3),Vector2(-8.4,-1.4),Vector2(-10.6,-3.),LOOKOUT])
	named_routes.append({"name":"home_lookout","controls":controls,"points":_smooth(controls),"radius":.92})
	_reindex_routes()

func height_at(x: float,z: float,enabled: bool) -> float:
	var base := super.height_at(x,z,enabled)
	if not enabled: return base
	# Broad shoulder to the west; the house and vegetable beds keep their level.
	var west := 1.-smoothstep(-11.8,-7.,x)
	var side := 1.-smoothstep(3.5,10.,absf(x+12.))
	var depth := 1.-smoothstep(3.5,9.,absf(z+4.5))
	return base+.95*west*side*depth
