extends "res://scripts/art/woodland_look89.gd"
var palette_day104 := -1.
func _shader_include() -> String:
 return super._shader_include()+"#include \"res://scripts/art/woodland_palette104.gdshaderinc\"\n"
func _shader_apply() -> String:
 return super._shader_apply()+"\n ALBEDO=woodland_palette104(ALBEDO,porch_position49);"
func _configure_material(material: ShaderMaterial) -> void:
 super._configure_material(material)
 if world.meadow!=null and not world.meadow.landmarks.is_empty(): material.set_shader_parameter("grove104",Vector2(world.meadow.landmarks.grove))
 material.set_shader_parameter("woodland_strength104",smoothstep(.05,.65,daylight55) if world.grade_enabled104 else 0.)
func apply_grade104() -> void:
 var strength := smoothstep(.05,.65,daylight55) if world.grade_enabled104 else 0.
 for material in materials.values(): material.set_shader_parameter("woodland_strength104",strength)
func apply_daylight(value: float) -> void:
 super.apply_daylight(value)
 if absf(value-palette_day104)<.001: return
 palette_day104=value;apply_grade104()
