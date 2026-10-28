extends "res://scripts/world/world40.gd"
## The gameplay baseline stays inherited; scenic composition lives separately.
var atmosphere41: Node3D

func _ready() -> void:
	super._ready()
	while not buff39_ready: await get_tree().physics_frame
	atmosphere41 = _atmosphere_script().new()
	atmosphere41.world = self
	add_child(atmosphere41)
	_title35()
	print("WORLD41_SCENERY_READY")

func _atmosphere_script() -> Script:
	return preload("res://scripts/art/woodland_atmosphere41.gd")

func _title35() -> void:
	DisplayServer.window_set_title("小白鹅 · 林间小院41 · F12 氛围 / Ctrl 光束 / Alt 景深 · F3 回家")

func _status() -> void:
	super._status()
	if world_ready: label.text=label.text.replace("连续世界40","连续世界41")

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and event.physical_keycode==KEY_F12 and is_instance_valid(atmosphere41):
		if event.alt_pressed: atmosphere41.toggle_focus()
		elif event.ctrl_pressed: atmosphere41.toggle_shafts()
		else: atmosphere41.set_enabled(not atmosphere41.enabled)
		return
	super._unhandled_input(event)
