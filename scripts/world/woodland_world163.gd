extends "res://scripts/world/woodland_world161.gd"
func _moment_manager161() -> Script: return preload("res://scripts/combat/pinwheel_stage163.gd")
func _title35() -> void: DisplayServer.window_set_title("小白鹅 · 163 · 课间幻想舞台 / 纸风车与蜜桃光膜")
func _ready() -> void:
 super._ready()
 while not is_instance_valid(moment161): await get_tree().physics_frame
 if "--stage163" in OS.get_cmdline_user_args(): trial152=true;paper_trial129=false;start_combat()
