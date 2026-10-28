extends "res://scripts/art/woodland_atmosphere43.gd"
var tone_profile := 0

func _ready() -> void:
	super._ready()
	focus_material.shader=preload("res://scripts/art/scenic_focus47.gdshader")
	_set_focus_level(focus_level)

func _set_focus_level(value: int) -> void:
	super._set_focus_level(value)
	focus_card.visible=enabled and (focus_enabled or tone_profile>0)

func set_tone(profile: int) -> void:
	tone_profile=profile
	focus_material.set_shader_parameter("tone_strength",0. if profile==0 else 1.)
	focus_material.set_shader_parameter("tone_contrast",1.055 if profile==1 else 1.025)
	focus_material.set_shader_parameter("tone_saturation",.94 if profile==1 else .93)
	focus_material.set_shader_parameter("tone_shadows",Vector3(.91,.97,1.035) if profile==1 else Vector3(.95,.985,1.025))
	focus_material.set_shader_parameter("tone_highlights",Vector3(1.025,1.01,.98) if profile==1 else Vector3(1.015,1.01,.99))
	focus_card.visible=enabled and (focus_enabled or tone_profile>0)

func _process(delta: float) -> void:
	super._process(delta)
	focus_card.visible=enabled and (focus_enabled or tone_profile>0)
