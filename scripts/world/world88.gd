extends "res://scripts/world/world87.gd"
func _forest_script87() -> Script: return preload("res://scripts/art/forest_props88.gd")
func _porch_script() -> Script: return preload("res://scripts/art/woodland_light88.gd")
func _title35() -> void: DisplayServer.window_set_title("小白鹅 · 88 · 自然林隙 / 石脚与植被归位")
func _assign_ground_materials() -> void:
	super._assign_ground_materials()
	# Keep local colour variation from masquerading as another broad shadow.
	var source := Shader.new()
	source.code=ground_shader87.code.replace("vec3(.30,.38,.19),.36","vec3(.36,.41,.23),.12")
	for material in ground_materials:
		material.shader=source
		if is_instance_valid(porch49): porch49.shade_material(material,source)
