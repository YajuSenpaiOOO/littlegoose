extends "res://scripts/world/world46.gd"
var lighting47: Node

func _atmosphere_script() -> Script:
	return preload("res://scripts/art/woodland_atmosphere47.gd")

func _life_script() -> Script:
	return preload("res://scripts/art/woodland_life47.gd")

func _ready() -> void:
	super._ready()
	while not is_instance_valid(woodland_life): await get_tree().physics_frame
	lighting47=_lighting_script().new()
	lighting47.world=self
	add_child(lighting47)
	_title35()
	print("WORLD47_LIGHTING_COMPARISON_READY")

func _lighting_script() -> Script:
	return preload("res://scripts/art/light_profiles47.gd")

func _title35() -> void:
	var profile := "暖阳深林影"
	if is_instance_valid(lighting47): profile=lighting47.NAMES[lighting47.profile]
	DisplayServer.window_set_title("小白鹅 · 光影对照47 · %s · Ctrl+7 原版 / 8 暖阳 / 9 薄雾"%profile)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and event.ctrl_pressed and is_instance_valid(lighting47):
		if event.physical_keycode in [KEY_7,KEY_8,KEY_9]:
			lighting47.set_profile(event.physical_keycode-KEY_7)
			return
	super._unhandled_input(event)
	if event is InputEventKey and event.pressed and not event.echo and event.physical_keycode==KEY_F12 and not event.ctrl_pressed and not event.alt_pressed and is_instance_valid(lighting47):
		if atmosphere41.enabled: lighting47.set_profile(lighting47.profile)
		else: atmosphere41.set_tone(0)

func _status() -> void:
	super._status()
	if world_ready:
		label.text=label.text.replace("连续世界46","连续世界47")
		label.text=label.text.replace("Ctrl+B/K/L 树冠/落叶/小灯 · Ctrl+T 材质 · Ctrl+F3 菜园","Ctrl+7/8/9 原版/暖阳/薄雾 · Ctrl+B/K/L 树冠/落叶/灯 · Ctrl+F3 菜园")
