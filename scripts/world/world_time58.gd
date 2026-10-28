extends "res://scripts/world/world_time57.gd"
var selected_rig58 := 0

func _accents_script() -> Script:
	return preload("res://scripts/art/night_accents58.gd")

func _ready() -> void:
	super._ready()
	world.atmosphere41.focus_material.shader=preload("res://scripts/art/scenic_day58.gdshader")
	world.atmosphere41._set_focus_level(world.atmosphere41.focus_level)
	set_rig58(0)
	print("WORLD58_SPOT_ONLY_AND_DEPTH_CONE_READY")

func set_rig58(value: int) -> void:
	selected_rig58=posmod(value,3)
	accents57.stage_enabled=selected_rig58!=1
	world.porch49.set_fill(selected_rig58!=0)
	apply_look()
	update_guide()

func update_guide() -> void:
	super.update_guide()
	if not is_instance_valid(accents57): return
	var stage: bool=accents57.stage_enabled
	var fill: bool=world.porch49.fill_enabled
	var text := "两者都关"
	if stage and fill: text="聚光＋随身补光"
	elif stage: text="仅舞台聚光"
	elif fill: text="仅随身补光"
	guide.text+="\nAlt+B 对照灯组：%s"%text

func handle_input(event: InputEvent) -> bool:
	if not sleeping and event is InputEventKey and event.pressed and not event.echo and event.alt_pressed and event.physical_keycode==KEY_B:
		set_rig58(selected_rig58+1)
		return true
	return super.handle_input(event)
