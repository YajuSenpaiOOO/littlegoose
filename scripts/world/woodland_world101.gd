extends "res://scripts/world/woodland_world100.gd"
var woodland_ready101 := false
var details101: Node3D
func _time_script() -> Script: return preload("res://scripts/world/woodland_time101.gd")
func _title35() -> void: DisplayServer.window_set_title("小白鹅 · 101 · 林地微景 / 路缘草石 / 蝶与鸟鸣")
func _ready() -> void:
 super._ready()
 while not woodland_ready100: await get_tree().physics_frame
 details101=_details_script101().new();details101.world=self;add_child(details101)
 woodland_ready101=true;_title35();time55.update_guide()
 print("WOODLAND101_READY details=",details101.props.size()," pebbles=",details101.pebbles.multimesh.instance_count," grass=",details101.grass.multimesh.instance_count)
func _unhandled_input(event: InputEvent) -> void:
 if event is InputEventKey and event.pressed and not event.echo and event.ctrl_pressed and event.alt_pressed and event.physical_keycode==KEY_A:
  if is_instance_valid(details101): details101.audio.set_enabled(not details101.audio.enabled)
  return
 super._unhandled_input(event)

func _details_script101() -> Script: return preload("res://scripts/art/woodland_details101.gd")
