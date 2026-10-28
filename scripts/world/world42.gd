extends "res://scripts/world/world41.gd"

func _ready() -> void:
	super._ready()
	while not is_instance_valid(atmosphere41): await get_tree().physics_frame
	while not is_instance_valid(atmosphere41.decor): await get_tree().physics_frame
	if "--catalog" in OS.get_cmdline_user_args(): atmosphere41.decor.toggle_catalog()
	print("WORLD42_DECORATION_CHOICES_READY")

func _atmosphere_script() -> Script:
	return preload("res://scripts/art/woodland_atmosphere42.gd")

func _title35() -> void:
	DisplayServer.window_set_title("小白鹅 · 装饰候选42 · Ctrl+F2 选素材 · Ctrl+F12 柔光 · Alt+F12 景深")

func _status() -> void:
	super._status()
	if world_ready: label.text=label.text.replace("连续世界41","连续世界42")

func fire_input_held() -> bool:
	if is_instance_valid(atmosphere41) and is_instance_valid(atmosphere41.decor) and atmosphere41.decor.catalog.visible: return false
	return super.fire_input_held()

func _unhandled_input(event: InputEvent) -> void:
	if is_instance_valid(atmosphere41) and is_instance_valid(atmosphere41.decor) and event is InputEventKey and event.pressed and not event.echo:
		if event.ctrl_pressed and event.physical_keycode==KEY_F2:
			atmosphere41.decor.toggle_catalog()
			return
		if atmosphere41.decor.catalog.visible and event.physical_keycode==KEY_ESCAPE:
			atmosphere41.decor.toggle_catalog()
			return
		if atmosphere41.decor.catalog.visible: return
	super._unhandled_input(event)
