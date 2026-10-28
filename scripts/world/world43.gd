extends "res://scripts/world/world42.gd"

func _ready() -> void:
	super._ready()
	while not is_instance_valid(atmosphere41): await get_tree().physics_frame
	while not atmosphere41.grass_ready: await get_tree().physics_frame
	print("WORLD43_LAYERED_VEGETATION_READY")

func _atmosphere_script() -> Script:
	return preload("res://scripts/art/woodland_atmosphere43.gd")

func _title35() -> void:
	var state := "浓"
	if is_instance_valid(atmosphere41): state=["关","轻","浓","重"][atmosphere41.focus_level]
	DisplayServer.window_set_title("小白鹅 · 植被层次43 · 景深：%s · Alt+F12 切换 · Ctrl+1/2/3 草/灌/花"%state)

func _status() -> void:
	super._status()
	if world_ready: label.text=label.text.replace("连续世界42","连续世界43")

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and event.alt_pressed and event.physical_keycode==KEY_F12 and is_instance_valid(atmosphere41):
		atmosphere41.toggle_focus()
		if is_instance_valid(atmosphere41.decor): atmosphere41.decor._update_focus_description()
		return
	if event is InputEventKey and event.pressed and not event.echo and event.ctrl_pressed and event.physical_keycode in [KEY_1,KEY_2,KEY_3] and is_instance_valid(atmosphere41):
		if wave_state=="waiting" and is_instance_valid(atmosphere41.decor):
			atmosphere41.decor.set_layer_stage(event.physical_keycode-KEY_1)
			if atmosphere41.decor.catalog.visible: atmosphere41.decor.toggle_catalog()
		return
	super._unhandled_input(event)
