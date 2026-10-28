extends Node2D
@export var profile: Resource
var ground_light: PointLight2D
var surface_light: PointLight2D
static var glow: GradientTexture2D

func _ready() -> void:
	if glow==null:
		var gradient := Gradient.new()
		gradient.set_color(0,Color.WHITE)
		gradient.set_color(1,Color(1,1,1,0))
		glow = GradientTexture2D.new()
		glow.width = 128
		glow.height = 128
		glow.fill = GradientTexture2D.FILL_RADIAL
		glow.fill_from = Vector2(0.5,0.5)
		glow.fill_to = Vector2(1,0.5)
		glow.gradient = gradient
	ground_light = _make_light(1,true)
	surface_light = _make_light(2,false)
	set_energy(profile.energy)
	add_to_group("station_emitters")

func _make_light(mask: int,shadows: bool) -> PointLight2D:
	var light := PointLight2D.new()
	light.texture = glow
	light.position = profile.emission_offset
	light.scale = profile.radius*2/128.0
	light.color = profile.color
	light.range_item_cull_mask = mask
	light.shadow_enabled = shadows and profile.casts_ground_shadows
	light.shadow_color = Color(0.07,0.08,0.15,0.55)
	light.shadow_filter = Light2D.SHADOW_FILTER_PCF5
	add_child(light)
	return light

func set_energy(value: float) -> void:
	if ground_light.energy!=value: ground_light.energy = value
	if surface_light.energy!=value: surface_light.energy = value

func set_shadows(value: bool) -> void:
	var enabled: bool = value and profile.casts_ground_shadows
	if ground_light.shadow_enabled!=enabled: ground_light.shadow_enabled = enabled

func projection_source() -> Dictionary:
	return {"light":ground_light,"anchor":self,"ground_offset":profile.ground_offset,"height":profile.virtual_height,"radius":profile.radius,"casts_actor_shadows":profile.casts_actor_shadows}
