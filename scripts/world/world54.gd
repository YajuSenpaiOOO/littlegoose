extends "res://scripts/world/world52.gd"
var enhanced54 := true
var guide54: Label

func _porch_script() -> Script:
	return preload("res://scripts/art/hero_fill54.gd")

func _ready() -> void:
	super._ready()
	while not is_instance_valid(sun_dust52): await get_tree().physics_frame
	guide54=Label.new()
	guide54.position=Vector2(24,150)
	guide54.add_theme_font_size_override("font_size",19)
	guide54.add_theme_color_override("font_shadow_color",Color.BLACK)
	guide54.add_theme_constant_override("shadow_offset_x",2)
	guide54.add_theme_constant_override("shadow_offset_y",2)
	label.get_parent().add_child(guide54)
	set_presence54(true)
	print("WORLD54_ORIGINAL_TERRAIN_STRONGER_MICRO_LIGHT_READY")

func set_presence54(value: bool) -> void:
	enhanced54=value
	if is_instance_valid(sun_dust52): sun_dust52.set_presence(2.1 if value else 1.,1.55 if value else 1.,1.7 if value else 1.,.25 if value else 0.)
	if is_instance_valid(porch49): porch49.set_presence(value)
	_title35()
	if is_instance_valid(guide54): guide54.text="54 · 尘屑与暖光：%s\nCtrl+6 原轻微版 / 加强版\nCtrl+J 尘屑 · Ctrl+U 暖光\nCtrl+F4 林路 · F3 小屋"%("加强" if value else "原轻微")

func _title35() -> void:
	var dust := "开"
	var fill := "开"
	if is_instance_valid(sun_dust52): dust="开" if sun_dust52.enabled else "关"
	if is_instance_valid(porch49): fill="开" if porch49.fill_enabled else "关"
	DisplayServer.window_set_title("小白鹅 · 微光加强54 · %s · Ctrl+6 对照 · Ctrl+J 尘屑%s / Ctrl+U 暖光%s"%["加强" if enhanced54 else "原轻微",dust,fill])

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and event.ctrl_pressed and event.physical_keycode==KEY_6:
		set_presence54(not enhanced54)
		return
	super._unhandled_input(event)

func _notification(what: int) -> void:
	if what==NOTIFICATION_WM_CLOSE_REQUEST: get_tree().quit()
