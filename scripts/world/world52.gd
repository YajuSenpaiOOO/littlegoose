extends "res://scripts/world/world51.gd"
var sun_dust52: Node3D

func _porch_script() -> Script:
	return preload("res://scripts/art/hero_fill52.gd")

func _ready() -> void:
	super._ready()
	while not is_instance_valid(porch49) or not porch49.is_node_ready(): await get_tree().physics_frame
	sun_dust52=preload("res://scripts/art/sun_dust52.gd").new()
	sun_dust52.world=self
	add_child(sun_dust52)
	_title35()
	print("WORLD52_DUST_AND_GENTLE_FILL_READY")

func _title35() -> void:
	var dust := "开"
	var fill := "开"
	if is_instance_valid(sun_dust52): dust="开" if sun_dust52.enabled else "关"
	if is_instance_valid(porch49): fill="开" if porch49.fill_enabled else "关"
	DisplayServer.window_set_title("小白鹅 · 林间微光52 · Ctrl+J 尘屑%s / Ctrl+U 暖补光%s · Ctrl+F4 林路"%[dust,fill])

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and event.ctrl_pressed:
		if event.physical_keycode==KEY_J and is_instance_valid(sun_dust52):
			sun_dust52.set_enabled(not sun_dust52.enabled)
			return
		if event.physical_keycode==KEY_U and is_instance_valid(porch49):
			porch49.set_fill(not porch49.fill_enabled)
			return
	super._unhandled_input(event)

func _status() -> void:
	super._status()
	if world_ready:
		label.text=label.text.replace("森林光影51","林间微光52")
		if not label.text.contains("Ctrl+J 尘屑"): label.text+="\nCtrl+J 尘屑 / Ctrl+U 主角暖补光"
