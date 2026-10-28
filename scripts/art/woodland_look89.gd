extends "res://scripts/art/woodland_light88.gd"
var look_enabled89 := true

func _shader_include() -> String:
	return super._shader_include().replace("route_light88.gdshaderinc","route_light89.gdshaderinc")

func _configure_material(material: ShaderMaterial) -> void:
	super._configure_material(material)
	material.set_shader_parameter("storybook89",1. if look_enabled89 else 0.)

func set_look89(value: bool) -> void:
	look_enabled89=value
	for material in materials.values():
		material.set_shader_parameter("storybook89",1. if value else 0.)
