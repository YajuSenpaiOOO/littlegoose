extends "res://scripts/art/night_accents58.gd"

func _cone_radius() -> float: return 3.8

func _ready() -> void:
	super._ready()
	stage_light.spot_angle=30.
	stage_light.spot_attenuation=2.
	stage_emitter.bind(preload("res://assets/lighting55/stage59.tres"),stage_light,stage_beam.material_override,&"strength57")

func set_strength(value: float) -> void:
	super.set_strength(value)
	world.atmosphere41.focus_material.set_shader_parameter("actor_stage57",strength*.7 if stage_enabled else 0.)
