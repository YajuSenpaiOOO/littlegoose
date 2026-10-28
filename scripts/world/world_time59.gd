extends "res://scripts/world/world_time58.gd"

func _accents_script() -> Script:
	return preload("res://scripts/art/night_accents59.gd")

func apply_look() -> void:
	super.apply_look()
	var material: ShaderMaterial=world.atmosphere41.focus_material
	material.set_shader_parameter("cone_density58",.13)
	material.set_shader_parameter("cone_spread58",.57735)
	material.set_shader_parameter("cone_radius58",3.8)
	material.set_shader_parameter("cone_tint58",Vector3(1.,.91,.75))

func update_guide() -> void:
	super.update_guide()
	var study: Node3D=world.get("bridge59")
	if not is_instance_valid(study): return
	guide.text+="\nAlt+5 A绳桥 / 6 B木桥 / 7 C石桥\nAlt+W 单换水面 · Ctrl+F6 到桥\n%s · %s"%[study.BRIDGES[study.bridge_style],study.WATERS[study.water_style]]
