extends "res://scripts/world/woodland_world164.gd"
func _moment_manager161() -> Script: return preload("res://scripts/combat/popup_stage165.gd")
func _title35() -> void: DisplayServer.window_set_title("小白鹅 · 165 · 课间立体书 / 弹起的幻想舞台")
func _ready() -> void:
 super._ready()
 while not is_instance_valid(moment161): await get_tree().physics_frame
 if "--popup165" in OS.get_cmdline_user_args(): trial152=true;paper_trial129=false;start_combat()
