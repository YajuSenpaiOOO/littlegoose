extends "res://scripts/world/world52.gd"
var lookout53: Node3D
var guide53: Label
var lookout_lift53 := 0.

func _update_camera(delta: float,snap := false) -> void:
	if is_instance_valid(camera): camera.position.y-=lookout_lift53
	super._update_camera(delta,snap)
	if not is_instance_valid(camera) or not is_instance_valid(hero): return
	var distance := Vector2(hero.position.x+12.,hero.position.z+5.2).length()
	var target := 3.*(1.-smoothstep(1.4,5.,distance))
	lookout_lift53=target if snap else move_toward(lookout_lift53,target,delta*3.)
	camera.position.y+=lookout_lift53

func _build_lab_floor() -> void:
	super._build_lab_floor()
	meadow=preload("res://scripts/world/world_surface53.gd").new()

func _ready() -> void:
	super._ready()
	while not is_instance_valid(sun_dust52): await get_tree().physics_frame
	lookout53=preload("res://scripts/art/lookout53.gd").new()
	lookout53.world=self
	add_child(lookout53)
	guide53=Label.new()
	guide53.position=Vector2(24,150)
	guide53.add_theme_font_size_override("font_size",19)
	guide53.add_theme_color_override("font_shadow_color",Color.BLACK)
	guide53.add_theme_constant_override("shadow_offset_x",2)
	guide53.add_theme_constant_override("shadow_offset_y",2)
	label.get_parent().add_child(guide53)
	guide53.text="53 · 缓坡与眺望口\nCtrl+F5 去眺望口 · F3 回小屋\nCtrl+7 树林遮挡 / 8 打开视野 / 9 远景层次\nCtrl+J 尘屑 · Ctrl+U 暖补光（轻微效果）"
	_title35()
	for arg in OS.get_cmdline_user_args():
		if arg=="--region=lookout": _travel_region("lookout")
	print("WORLD53_LOOKOUT_READY")

func _travel_region(key: String) -> void:
	if key=="lookout":
		_teleport15(Vector2(-12.,-5.2))
		return
	super._travel_region(key)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and event.ctrl_pressed:
		if event.physical_keycode==KEY_F5:
			_travel_region("lookout")
			return
		if event.physical_keycode in [KEY_7,KEY_8,KEY_9] and is_instance_valid(lookout53):
			lookout53.set_mode(event.physical_keycode-KEY_7)
			return
	super._unhandled_input(event)

func _title35() -> void:
	var selected := "开口＋远景层次"
	if is_instance_valid(lookout53): selected=lookout53.LABELS[lookout53.mode]
	DisplayServer.window_set_title("小白鹅 · 眺望口53 · %s · Ctrl+F5 眺望口 · Ctrl+7/8/9 对照"%selected)

func _notification(what: int) -> void:
	if what==NOTIFICATION_WM_CLOSE_REQUEST: get_tree().quit()
