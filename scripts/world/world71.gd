extends "res://scripts/world/world69.gd"
var region71: Node3D
var review71 := false
var review_anchor71 := Vector3.ZERO

func _build_lab_floor() -> void:
	super._build_lab_floor()
	meadow=preload("res://scripts/world/world_surface71.gd").new()

func _time_script() -> Script:
	return preload("res://scripts/world/world_time71.gd")

func _ready() -> void:
	super._ready()
	while not is_instance_valid(local68): await get_tree().physics_frame
	region71=preload("res://scripts/art/woodland_region71.gd").new()
	region71.world=self; add_child(region71)
	await get_tree().physics_frame
	await get_tree().physics_frame
	navigation.bake(get_world_3d().direct_space_state,meadow,meadow.landmarks.grove)
	if not "--combat" in OS.get_cmdline_user_args(): _teleport15(meadow.landmarks.grove+Vector2(3,13.5))
	_title35()
	print("WORLD71_WOODED_HIGHLAND_READY")

func _title35() -> void:
	DisplayServer.window_set_title("小白鹅 · 林地山麓71 · 连片高地 / 树带 / 绘本岩山")

func _process(delta: float) -> void:
	super._process(delta)
	if not review71: return
	if hero.global_position.distance_to(review_anchor71)>.25:
		review71=false; return
	var g: Vector2=meadow.landmarks.grove
	camera.global_position=Vector3(g.x,5.,g.y-3.)+camera.global_basis.z*37.

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and not event.alt_pressed and not event.ctrl_pressed:
		if event.physical_keycode==KEY_9:
			review71=not review71; review_anchor71=hero.global_position; return
		if event.physical_keycode in [KEY_7,KEY_8]:
			review71=false
			_teleport15(meadow.landmarks.grove+(Vector2(3,13.5) if event.physical_keycode==KEY_7 else Vector2(20,-1)))
			return
	super._unhandled_input(event)
