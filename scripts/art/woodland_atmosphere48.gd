extends "res://scripts/art/woodland_atmosphere47.gd"
var stage_level := 0

func _ready() -> void:
	super._ready()
	focus_material.shader=preload("res://scripts/art/scenic_stage48.gdshader")
	_set_focus_level(focus_level)

func set_stage(value: int) -> void:
	stage_level=clampi(value,0,2)
	focus_material.set_shader_parameter("stage_strength",0. if stage_level==0 else 1.)
	focus_material.set_shader_parameter("glow_strength",.55 if stage_level==2 else 0.)
	focus_card.visible=enabled and (focus_enabled or stage_level>0)

func _set_focus_level(value: int) -> void:
	super._set_focus_level(value)
	focus_card.visible=enabled and (focus_enabled or stage_level>0)

func _process(delta: float) -> void:
	super._process(delta)
	focus_card.visible=enabled and (focus_enabled or stage_level>0)
