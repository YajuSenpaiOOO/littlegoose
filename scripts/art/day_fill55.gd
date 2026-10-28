extends "res://scripts/art/hero_fill54.gd"
var daylight55 := 1.

func _route_strength() -> float: return lerpf(.22,1.,daylight55)

func desired_fill() -> float:
	if not fill_enabled: return 0.
	return maxf(super.desired_fill(),(1.-daylight55)*.62)

func apply_daylight(value: float) -> void:
	daylight55=value
	for material in materials.values():
		material.set_shader_parameter("route_strength50",_route_strength())
		material.set_shader_parameter("porch_light_strength49",lerpf(.38,1.,value) if profile==2 else 0.)
	house_material.set_shader_parameter("porch_light_strength49",lerpf(.38,1.,value) if profile==2 else 0.)
