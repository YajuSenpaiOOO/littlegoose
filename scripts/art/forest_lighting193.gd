extends "res://scripts/art/forest_lighting192.gd"
func _ready() -> void:
 super._ready()
 # Spread existing fixtures instead of adding more competing point lights.
 for light in lamps:
  light.omni_range*=1.35;light.omni_attenuation=1.05
 _process(0.)
func _process(delta: float) -> void:
 super._process(delta)
 if not is_instance_valid(world.time55) or not is_instance_valid(world.time55.accents57): return
 var spot: SpotLight3D=world.time55.accents57.stage_light
 spot.light_color=Color("ffc584");spot.light_energy=1.65*stage_level
 # Slightly forward so the upright actor receives the stage rather than just grass.
 spot.position=Vector3(-.45,5.,2.2);spot.look_at(world.hero.global_position+Vector3.UP*.7,Vector3.UP)
 spot.spot_angle=25.;spot.spot_attenuation=1.3
