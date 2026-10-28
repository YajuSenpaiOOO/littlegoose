extends "res://scripts/world/world_time83.gd"
var noon_enabled85 := true
var noon_shader85: Shader

func _ready() -> void:
	super._ready()
	noon_shader85=preload("res://scripts/art/scenic_day85.gdshader")
	world.atmosphere41.focus_material.shader=noon_shader85
	world.atmosphere41._set_focus_level(world.atmosphere41.focus_level)
	apply_look()

func noon_weight85(hour: float) -> float:
	return smoothstep(8.5,11.,hour)*(1.-smoothstep(13.,16.,hour)) if noon_enabled85 else 0.

func apply_look() -> void:
	super.apply_look()
	if noon_shader85==null: return
	var weight := noon_weight85(visual_hour)
	var env: Environment=world.atmosphere41.environment
	env.ambient_light_color=env.ambient_light_color.lerp(Color("b7c9df"),weight)
	env.ambient_light_energy=lerpf(env.ambient_light_energy,.48,weight)
	world.sun.light_energy=lerpf(world.sun.light_energy,.92,weight)
	world.sun.light_color=world.sun.light_color.lerp(Color("fff3da"),weight)
	var focus: ShaderMaterial=world.atmosphere41.focus_material
	focus.set_shader_parameter("noon_strength85",weight)
	focus.set_shader_parameter("day_exposure55",lerpf(float(palette.sample(visual_hour).exposure),1.,weight))
	focus.set_shader_parameter("haze_strength57",lerpf(.035,.13,weight) if haze_enabled57 else 0.)
	# Preserve the accepted night haze exactly; super sets it from daylight.
	if weight<=0.:
		focus.set_shader_parameter("haze_strength57",lerpf(.035,.085,1.-float(palette.sample(visual_hour).daylight)) if haze_enabled57 else 0.)
	else: focus.set_shader_parameter("haze_color57",Vector3(.56,.65,.71))

func update_guide() -> void:
	super.update_guide()
	if is_instance_valid(guide): guide.text+="\n85：Ctrl+Alt+N 正午层次[%s]"%["开" if noon_enabled85 else "旧版"]

func handle_input(event: InputEvent) -> bool:
	if event is InputEventKey and event.pressed and not event.echo and event.ctrl_pressed and event.alt_pressed and event.physical_keycode==KEY_N:
		noon_enabled85=not noon_enabled85;apply_look();update_guide();return true
	return super.handle_input(event)
