extends "res://scripts/world/world_time55.gd"
var window_spill56: OmniLight3D
var original_ray_direction := Vector3.ZERO

func _ready() -> void:
	palette=_day_palette()
	original_ray_direction=-world.sun.global_basis.z.normalized()
	for beam in world.atmosphere41.shafts.get_children():
		beam.material_override.shader=preload("res://scripts/art/soft_shaft56.gdshader")
	super._ready()
	world.atmosphere41.focus_material.shader=preload("res://scripts/art/scenic_day56.gdshader")
	world.atmosphere41._set_focus_level(world.atmosphere41.focus_level)
	window_spill56=OmniLight3D.new()
	window_spill56.name="CottageWarmSpill_NoShadow"
	window_spill56.light_color=Color("ffc181")
	window_spill56.omni_range=5.8
	window_spill56.omni_attenuation=1.6
	window_spill56.shadow_enabled=false
	add_child(window_spill56)
	window_spill56.global_position=Vector3(-4.7,world.floor_height(Vector2(-4.7,-3.2))+1.5,-3.2)
	apply_look()
	print("WORLD56_BLUE_NIGHT_AND_MOVING_SHADOWS_READY")

func _day_palette() -> Resource:
	return preload("res://assets/lighting55/woodland_day56.tres")

func _apply_sun_pose(look: Dictionary) -> void:
	world.sun.rotation_degrees=Vector3(-look.elevation56,look.azimuth56,0.)
	world.sun.shadow_opacity=look.shadow_opacity56

func apply_look() -> void:
	var look: Dictionary=palette.sample(visual_hour)
	_apply_sun_pose(look)
	super.apply_look()
	var night := 1.-float(look.daylight)
	var focus: ShaderMaterial=world.atmosphere41.focus_material
	focus.set_shader_parameter("night_mix56",night)
	focus.set_shader_parameter("tone_contrast",lerpf(1.025,.96,night))
	focus.set_shader_parameter("stage_strength",lerpf(1.,.48,night) if world.atmosphere41.stage_level>0 else 0.)
	# Native tree/house/furniture shadows and projected actors use the same ray.
	var direction: Vector3=-world.sun.global_basis.z.normalized()
	for shadow in world.actor_shadows:
		if not is_instance_valid(shadow): continue
		shadow.light_direction=direction
		shadow.opacity_scale=lerpf(1.,.4,night)
	for beam in world.atmosphere41.shafts.get_children():
		beam.material_override.set_shader_parameter("ray_shift56",-(direction-original_ray_direction)*8.4)
	var life: Node3D=world.woodland_life
	life.lantern_light.omni_range=lerpf(2.9,5.,night)
	life.lantern_light.omni_attenuation=1.5
	life.lantern_light.light_energy=lerpf(.22,2.4,float(look.lamps))
	if is_instance_valid(window_spill56):
		window_spill56.light_energy=2.6*night
		window_spill56.visible=night>.005 and world.house_art.visible
