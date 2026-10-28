extends "res://scripts/art/woodland_palette104.gd"
func strength108() -> float:
 if not world.grade_enabled104: return 0.
 var strength := smoothstep(.05,.65,daylight55)
 if is_instance_valid(world.time55) and world.time55.get("depth_enabled108")==true:
  strength=maxf(strength,smoothstep(18.5,20.5,world.time55.visual_hour)*.50)
 return strength
func _configure_material(material: ShaderMaterial) -> void:
 super._configure_material(material);material.set_shader_parameter("woodland_strength104",strength108())
func apply_grade104() -> void:
 var strength := strength108()
 for material in materials.values(): material.set_shader_parameter("woodland_strength104",strength)
