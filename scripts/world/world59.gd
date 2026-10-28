extends "res://scripts/world/world58.gd"
var bridge59: Node3D
var old_bridge59: Array[MeshInstance3D] = []

func _time_script() -> Script:
	return preload("res://scripts/world/world_time59.gd")

func _bridge_script() -> Script:
	return preload("res://scripts/art/bridge_lake59.gd")

func _build_water_and_bridge() -> void:
	var before := get_child_count()
	super._build_water_and_bridge()
	for i in range(before,get_child_count()):
		var child := get_child(i)
		if child is MeshInstance3D and child.material_override!=water_material19:
			old_bridge59.append(child)
			child.hide()

func _ready() -> void:
	super._ready()
	while not is_instance_valid(time55) or not time55.is_node_ready(): await get_tree().physics_frame
	bridge59=_bridge_script().new()
	bridge59.world=self
	add_child(bridge59)
	if not "--combat" in OS.get_cmdline_user_args(): go_bridge59()
	time55.update_guide()
	_title35()
	print("WORLD59_THREE_BRIDGES_AND_LAKES_READY")

func go_bridge59() -> void:
	if combat_ready: _leave_encounter()
	_teleport15(meadow.bridge_rect.get_center())

func _title35() -> void:
	var selected := "三版对照"
	if is_instance_valid(bridge59): selected=bridge59.BRIDGES[bridge59.bridge_style]+" · "+bridge59.WATERS[bridge59.water_style]
	DisplayServer.window_set_title("小白鹅 · 桥与湖59 · %s · Alt+5/6/7 三版 · Alt+W 水面"%selected)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and is_instance_valid(bridge59):
		if event.alt_pressed and event.physical_keycode in [KEY_5,KEY_6,KEY_7]:
			bridge59.set_pair(event.physical_keycode-KEY_5)
			time55.update_guide()
			return
		if event.alt_pressed and event.physical_keycode==KEY_W:
			bridge59.set_water(bridge59.water_style+1)
			time55.update_guide()
			return
		if event.ctrl_pressed and event.physical_keycode==KEY_F6:
			go_bridge59()
			return
	super._unhandled_input(event)
