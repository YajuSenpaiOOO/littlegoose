extends "res://scripts/world/woodland_world107.gd"
var woodland_ready108 := false
func _time_script() -> Script: return preload("res://scripts/world/woodland_time108.gd")
func _lamps_script106() -> Script: return preload("res://scripts/art/woodland_lamps108.gd")
func _park_script99() -> Script: return preload("res://scripts/art/nature_park108.gd")
func _porch_script() -> Script: return preload("res://scripts/art/woodland_palette108.gd")
func _title35() -> void: DisplayServer.window_set_title("小白鹅 · 108 · 林荫明暗 / 夜灯投影 / 苔木")
func _ready() -> void:
 super._ready()
 while not woodland_ready107: await get_tree().physics_frame
 woodland_ready108=true;_title35();time55.update_guide();print("WOODLAND108_READY")
