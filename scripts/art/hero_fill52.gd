extends "res://scripts/art/woodland_light_controller51.gd"
var fill_enabled := true
var fill_strength := 0.
var warm_light: OmniLight3D
var fill_gains := Vector3(.13,.065,.012)
var fill_minimum := 0.
var fill_energy := .12
var fill_range := 1.45

func _ready() -> void:
	super._ready()
	warm_light=OmniLight3D.new()
	warm_light.name="GentleHeroFill_NoShadow"
	warm_light.light_color=Color("ffe6ba")
	warm_light.omni_range=fill_range
	warm_light.omni_attenuation=2.
	warm_light.shadow_enabled=false
	add_child(warm_light)
	set_fill(true)

func desired_fill() -> float:
	if not fill_enabled or field_image==null: return 0.
	var p: Vector3=world.hero.global_position
	var field := sample_field(Vector2(p.x,p.z))
	var luma := (field.r*.2126+field.g*.7152+field.b*.0722)*1.25
	luma=lerpf(1.,luma,field.a)
	return lerpf(fill_minimum,1.,1.-smoothstep(.71,1.015,luma))

func set_fill(value: bool) -> void:
	fill_enabled=value
	fill_strength=desired_fill()
	_update_actor()
	world._title35()

func _process(delta: float) -> void:
	fill_strength=move_toward(fill_strength,desired_fill(),delta*2.)
	super._process(delta)

func _update_actor() -> void:
	super._update_actor()
	# Multiply existing feedback rather than replacing damage/dodge colors.
	var strength := fill_strength if fill_enabled else 0.
	world.hero.visual.modulate*=Color(1.+strength*fill_gains.x,1.+strength*fill_gains.y,1.+strength*fill_gains.z)
	if is_instance_valid(warm_light):
		warm_light.global_position=world.hero.global_position+Vector3.UP*.85
		warm_light.light_energy=fill_energy*strength
		warm_light.visible=fill_enabled and strength>.005
