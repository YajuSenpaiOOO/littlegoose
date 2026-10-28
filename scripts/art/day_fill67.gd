extends "res://scripts/art/day_fill58.gd"
var last_daylight67 := -1.
var last_profile67 := -1
var daylight_pushes67 := 0

func _configure_material(material: ShaderMaterial) -> void:
	super._configure_material(material)
	# A newly switched fade shader receives the current daylight immediately.
	material.set_shader_parameter("porch_light_strength49",lerpf(.38,1.,daylight55) if profile==2 else 0.)

func apply_daylight(value: float) -> void:
	daylight55=value
	if is_equal_approx(value,last_daylight67) and profile==last_profile67: return
	super.apply_daylight(value)
	last_daylight67=value
	last_profile67=profile
	daylight_pushes67+=1
