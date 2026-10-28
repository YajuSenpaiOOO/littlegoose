extends "res://scripts/world/woodland_world95.gd"
var woodland_ready96 := false
const LAYOUT96=preload("res://scripts/world/rest_layout96.gd")
func _forest_script87() -> Script: return preload("res://scripts/art/forest_props96.gd")
func _rock_surfaces_script91() -> Script: return preload("res://scripts/art/rock_surfaces96.gd")
func _time_script() -> Script: return preload("res://scripts/world/woodland_time96.gd")
func _title35() -> void: DisplayServer.window_set_title("小白鹅 · 96 · 林间小憩 / 低花草甸 / 浅踏草径")
func _build_lab_floor() -> void:
	super._build_lab_floor();meadow=preload("res://scripts/world/world_surface96.gd").new()
func _grass_growth92(at: Vector2) -> float:
	var growth := super._grass_growth92(at)
	var local: Vector2=at-Vector2(meadow.landmarks.grove)
	return lerpf(growth,.12,LAYOUT96.trail96(local))
func _ready() -> void:
	super._ready()
	while not woodland_ready95: await get_tree().physics_frame
	woodland_ready96=true;_title35();time55.update_guide()
	print("WOODLAND96_READY")
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and event.ctrl_pressed and event.alt_pressed and event.physical_keycode==KEY_F2:
		set_review72(false);_teleport15(meadow.landmarks.grove+Vector2(-8,3));return
	super._unhandled_input(event)
