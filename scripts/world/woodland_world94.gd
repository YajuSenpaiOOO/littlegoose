extends "res://scripts/world/woodland_world93.gd"
var woodland_ready94 := false
func _forest_script87() -> Script: return preload("res://scripts/art/forest_props94.gd")
func _time_script() -> Script: return preload("res://scripts/world/woodland_time94.gd")
func _title35() -> void: DisplayServer.window_set_title("小白鹅 · 94 · 林隙花丛 / 植被碰触回弹")
func _ready() -> void:
	super._ready()
	while not woodland_ready93: await get_tree().physics_frame
	woodland_ready94=true;_title35();time55.update_guide()
	print("WOODLAND94_READY")

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and event.ctrl_pressed and event.alt_pressed and event.physical_keycode==KEY_F2:
		set_review72(false);_teleport15(meadow.landmarks.grove+Vector2(-3,-1));return
	super._unhandled_input(event)
