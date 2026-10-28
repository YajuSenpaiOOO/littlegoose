extends "res://scripts/world/world54.gd"
var time55: Node

func _porch_script() -> Script:
	return preload("res://scripts/art/day_fill55.gd")

func _ready() -> void:
	super._ready()
	while not is_instance_valid(guide54): await get_tree().physics_frame
	guide54.hide()
	time55=_time_script().new()
	time55.world=self
	add_child(time55)
	_title35()
	print("WORLD55_CONTINUOUS_DAY_READY")

func _time_script() -> Script:
	return preload("res://scripts/world/world_time55.gd")

func _title35() -> void:
	DisplayServer.window_set_title("小白鹅 · 晨昏55 · Alt+1/2/3/4 时段预览 · Alt+T 加速 · Alt+0 自然流动")

func _unhandled_input(event: InputEvent) -> void:
	if is_instance_valid(time55) and time55.handle_input(event): return
	super._unhandled_input(event)
