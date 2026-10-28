extends "res://scripts/world/world43.gd"
var garden: Node3D

func _ready() -> void:
	super._ready()
	while not is_instance_valid(atmosphere41): await get_tree().physics_frame
	while not atmosphere41.grass_ready: await get_tree().physics_frame
	garden=_garden_script().new()
	garden.world=self
	add_child(garden)
	_title35()
	print("WORLD44_KITCHEN_GARDEN_READY")

func _garden_script() -> Script:
	return preload("res://scripts/art/kitchen_garden44.gd")

func _title35() -> void:
	DisplayServer.window_set_title("小白鹅 · 生活小院44 · Ctrl+F3 菜园 · Ctrl+G 庭院对照 · Alt+F12 景深")

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and is_instance_valid(garden):
		if event.ctrl_pressed and event.physical_keycode==KEY_G:
			garden.set_enabled(not garden.enabled)
			atmosphere41._apply_grass(atmosphere41.enabled)
			garden.sync_grass_cutouts()
			return
		if event.ctrl_pressed and event.physical_keycode==KEY_F3:
			_travel_region("home")
			_teleport15(Vector2(.88,-2.7))
			return
	super._unhandled_input(event)
	if event is InputEventKey and event.pressed and not event.echo and event.physical_keycode==KEY_F12 and not event.ctrl_pressed and not event.alt_pressed and is_instance_valid(garden):
		garden.set_enabled(atmosphere41.enabled)
		atmosphere41._apply_grass(atmosphere41.enabled)
		garden.sync_grass_cutouts()

func _status() -> void:
	super._status()
	if world_ready: label.text=label.text.replace("连续世界43","连续世界44")
