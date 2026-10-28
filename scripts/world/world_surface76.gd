extends "res://scripts/world/world_surface75.gd"
const FIELD_RADII76 := Vector2(20.,15.)
const ROOT_BUFFER76 := Vector2(23.,18.)

func _init() -> void:
	super._init()
	for clearing in clearings:
		if clearing.at.distance_to(landmarks.grove)<1.: clearing.radius=FIELD_RADII76

func is_open_ground(at: Vector2) -> bool:
	if ((at-Vector2(landmarks.grove))/ROOT_BUFFER76).length()<1.: return true
	if at.x> -33. and at.x< -21. and at.y> -34. and at.y< -26.: return true
	return super.is_open_ground(at)

func regional_front75(x: float) -> float:
	var woodland: float=(1.-smoothstep(-27.,-17.,x))*smoothstep(-82.,-72.,x)
	return lerpf(super.regional_front75(x),-24.8+.6*sin(x*.08),woodland)

func upper_front73(x: float) -> float:
	# Broaden the real wooded shelf instead of creating an arena-height island.
	return front72(x)-40.
