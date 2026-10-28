extends Node
## Bind one existing light and/or one shared material. Never spawns shadow maps.
var preset: Resource
var light: Light3D
var material: ShaderMaterial
var parameter: StringName

func bind(settings: Resource,target: Light3D,surface: ShaderMaterial,emission_parameter: StringName) -> void:
	preset=settings
	light=target
	material=surface
	parameter=emission_parameter
	if is_instance_valid(light):
		light.light_color=preset.color
		light.shadow_enabled=false

func set_level(spill: float,core: float,enabled := true) -> void:
	var next := Vector2(clampf(spill,0.,1.),clampf(core,0.,1.)) if enabled else Vector2.ZERO
	# The time controller may have touched this existing light in its parent.
	if is_instance_valid(light):
		light.light_color=preset.color
		light.light_energy=lerpf(preset.spill_day,preset.spill_night,next.x) if enabled else 0.
		if light is OmniLight3D: light.omni_range=lerpf(preset.range_day,preset.range_night,next.x)
		elif light is SpotLight3D: light.spot_range=lerpf(preset.range_day,preset.range_night,next.x)
	if material!=null:
		material.set_shader_parameter(parameter,lerpf(preset.core_day,preset.core_night,next.y) if enabled else 0.)
