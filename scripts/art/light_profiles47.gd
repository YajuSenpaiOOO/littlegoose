extends Node
const NAMES := ["原版","暖阳深林影","薄雾柔光"]
const ENV_FIELDS := ["ambient_light_color","ambient_light_energy","fog_enabled","fog_mode","fog_depth_begin","fog_depth_end","fog_depth_curve","fog_density","fog_light_color","fog_light_energy"]
var world: Node3D
var profile := 1
var base := {}
var base_sun_color: Color
var base_sun_energy: float

func _ready() -> void:
	var environment: Environment=world.atmosphere41.environment
	for key in ENV_FIELDS: base[key]=environment.get(key)
	base_sun_color=world.sun.light_color
	base_sun_energy=world.sun.light_energy
	set_profile(1)

func restore_base() -> void:
	var atmosphere: Node3D=world.atmosphere41
	for key in ENV_FIELDS: atmosphere.environment.set(key,base[key])
	world.sun.light_color=base_sun_color
	world.sun.light_energy=base_sun_energy
	atmosphere.set_tone(0)
	atmosphere.shafts_enabled=false
	atmosphere.shafts.hide()

func set_profile(value: int) -> void:
	profile=clampi(value,0,2)
	restore_base()
	var atmosphere: Node3D=world.atmosphere41
	var environment: Environment=atmosphere.environment
	if profile==1:
		environment.ambient_light_color=Color("91abc0")
		environment.ambient_light_energy=.235
		world.sun.light_color=Color("fff0d8")
		world.sun.light_energy=.90
		# Slightly cooler, quieter distance; keep the house and walking plane clear.
		environment.fog_light_color=Color("94aba8")
		environment.fog_depth_begin=27.
		environment.fog_depth_end=92.
	elif profile==2:
		environment.ambient_light_color=Color("abbfc5")
		environment.ambient_light_energy=.27
		world.sun.light_color=Color("fff1da")
		world.sun.light_energy=.83
		environment.fog_light_color=Color("b8c8bf")
		environment.fog_depth_begin=19.
		environment.fog_depth_end=48.
		environment.fog_depth_curve=1.25
		environment.fog_light_energy=.72
		atmosphere.shafts_enabled=true
		atmosphere.shafts.visible=atmosphere.enabled
	atmosphere.set_tone(profile)
	for i in atmosphere.shafts.get_child_count():
		var beam: MeshInstance3D=atmosphere.shafts.get_child(i)
		# Two low-density accents at existing canopy openings, not full-screen bars.
		beam.visible=i in [0,2]
		beam.material_override.set_shader_parameter("strength",.105 if i==0 else .085)
	world._title35()
