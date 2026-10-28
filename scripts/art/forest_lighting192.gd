extends "res://scripts/art/forest_lighting191.gd"
func _ready() -> void:
 super._ready()
 for light in lamps: light.set_meta("energy191",float(light.get_meta("energy191"))*.5)
 _process(0.)
func _process(delta: float) -> void:
 super._process(delta)
 if not is_instance_valid(world.time55) or not is_instance_valid(world.time55.accents57): return
 var spot: SpotLight3D=world.time55.accents57.stage_light
 spot.light_color=Color("ffd39b");spot.light_energy=1.2*stage_level
 world.time55.accents57.stage_beam.material_override.set_shader_parameter("strength57",stage_level*.015)
