extends "res://scripts/world/woodland_world105.gd"
var woodland_ready106 := false
var lamps106: Node3D
func _lamps_script106() -> Script: return preload("res://scripts/art/woodland_lamps106.gd")
func _details_script101() -> Script: return preload("res://scripts/art/woodland_details106.gd")
func _time_script() -> Script: return preload("res://scripts/world/woodland_time106.gd")
func _title35() -> void: DisplayServer.window_set_title("小白鹅 · 106 · 静叶无声 / 树下暖灯")
func _ready() -> void:
 super._ready()
 while not woodland_ready105: await get_tree().physics_frame
 lamps106=_lamps_script106().new();lamps106.world=self;add_child(lamps106)
 woodland_ready106=true;_title35();time55.update_guide();print("WOODLAND106_READY static_leaves=",details101.leaf_states102.size()," lamps=",lamps106.lamps106.size())
func _unhandled_input(event: InputEvent) -> void:
 if event is InputEventKey and event.pressed and not event.echo and event.ctrl_pressed and event.alt_pressed and event.physical_keycode==KEY_F7:
  if is_instance_valid(lamps106): lamps106.enabled106=not lamps106.enabled106;lamps106.update106()
  return
 super._unhandled_input(event)
