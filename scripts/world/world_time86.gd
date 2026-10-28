extends "res://scripts/world/world_time85.gd"
var heat_enabled86 := false
var vignette_enabled86 := true
var focus_mode86 := 0
const FOCUS_TAPS86 := [24,12,0]
const FOCUS_LABELS86 := ["原质量","轻量","关闭"]
var effects_ready86 := false

func _init() -> void:
	noon_enabled85=false

func _ready() -> void:
	super._ready()
	noon_shader85=preload("res://scripts/art/scenic_day86.gdshader")
	world.atmosphere41.focus_material.shader=noon_shader85
	world.atmosphere41._set_focus_level(world.atmosphere41.focus_level)
	effects_ready86=true;apply_look();update_guide()

func apply_look() -> void:
	super.apply_look()
	if not effects_ready86: return
	var weight := noon_weight85(visual_hour)
	# Neutral white noon sun distinguishes it from warm dawn and amber sunset.
	world.sun.light_color=palette.sample(visual_hour).sun
	var focus: ShaderMaterial=world.atmosphere41.focus_material
	focus.set_shader_parameter("heat_strength86",weight if heat_enabled86 else 0.)
	focus.set_shader_parameter("vignette86",.22 if vignette_enabled86 else 0.)
	focus.set_shader_parameter("focus_samples86",maxi(1,FOCUS_TAPS86[focus_mode86]))
	focus.set_shader_parameter("radius_pixels",0. if focus_mode86==2 else 6.2)

func update_guide() -> void:
	super.update_guide()
	if is_instance_valid(guide):
		guide.text+="\n86：Ctrl+Alt+H 远地热浪[%s]\nCtrl+Alt+V 微暗角[%s] · D 景深[%s]"%["开" if heat_enabled86 else "关","开" if vignette_enabled86 else "关",FOCUS_LABELS86[focus_mode86]]

func handle_input(event: InputEvent) -> bool:
	if event is InputEventKey and event.pressed and not event.echo and event.ctrl_pressed and event.alt_pressed:
		match event.physical_keycode:
			KEY_H: heat_enabled86=not heat_enabled86
			KEY_V: vignette_enabled86=not vignette_enabled86
			KEY_D: focus_mode86=(focus_mode86+1)%3
			_: return super.handle_input(event)
		apply_look();update_guide();return true
	return super.handle_input(event)
