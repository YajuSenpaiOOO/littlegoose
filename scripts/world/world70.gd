extends "res://scripts/world/world69.gd"
var terrace70: Node3D

func _build_lab_floor() -> void:
	super._build_lab_floor()
	meadow=preload("res://scripts/world/world_surface70.gd").new()

func _time_script() -> Script:
	return preload("res://scripts/world/world_time70.gd")

func _ready() -> void:
	super._ready()
	while not is_instance_valid(local68): await get_tree().physics_frame
	terrace70=preload("res://scripts/art/forest_terrace70.gd").new()
	terrace70.world=self; add_child(terrace70)
	await get_tree().physics_frame
	await get_tree().physics_frame
	navigation.bake(get_world_3d().direct_space_state,meadow,meadow.landmarks.grove)
	if not "--combat" in OS.get_cmdline_user_args(): _teleport15(meadow.landmarks.grove+Vector2(-3,15.5))
	_title35()
	print("WORLD70_LAYERED_FOREST_READY")

func _title35() -> void:
	DisplayServer.window_set_title("小白鹅 · 石阶林地70 · 岩壁 / 高台 / 侧坡")

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and not event.alt_pressed and not event.ctrl_pressed:
		if event.physical_keycode in [KEY_7,KEY_8]:
			_teleport15(meadow.landmarks.grove+(Vector2(-3,15.5) if event.physical_keycode==KEY_7 else Vector2(19,0)))
			return
	super._unhandled_input(event)
