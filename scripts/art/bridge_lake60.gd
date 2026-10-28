extends "res://scripts/art/bridge_lake59.gd"
const WATER_LEVEL := -.68
var moving := true
var sparkling := true

func _shore_water_height() -> float:
	return WATER_LEVEL+.025

func _water_shader() -> Shader:
	return preload("res://scripts/art/lake60.gdshader")

func _ready() -> void:
	super._ready()
	name="LivingLake60"
	world.water_material19.shader=_water_shader()
	# Shared uniform names retain the existing painted base and geographic shore mask.
	for child in world.get_children():
		if child is MeshInstance3D and child.material_override==world.water_material19:
			child.position.y=WATER_LEVEL-(-.28)
	set_water(water_style)
	set_motion(true)
	set_sparkles(true)

func set_motion(enabled: bool) -> void:
	if moving and not enabled:
		world.water_material19.set_shader_parameter("frozen60",world.clock)
	moving=enabled
	world.water_material19.set_shader_parameter("motion60",moving)

func set_sparkles(enabled: bool) -> void:
	sparkling=enabled
	world.water_material19.set_shader_parameter("sparkle60",sparkling)
