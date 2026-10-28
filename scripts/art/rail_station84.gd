extends "res://scripts/art/rail_station83.gd"
func material79() -> ShaderMaterial:
	var material := ShaderMaterial.new();material.shader=preload("res://scripts/art/stone84.gdshader")
	material.set_shader_parameter("face_paint79",preload("res://assets/wall77/painted_moss_stone77.png"))
	material.set_shader_parameter("top_paint84",preload("res://assets/stone84/painted_limestone_top84.png"));world.porch49.shade_material(material);return material
func _build_side_steps75() -> void:
	super._build_side_steps75()
	side_steps80.material_override.set_shader_parameter("stair_top84",true)
