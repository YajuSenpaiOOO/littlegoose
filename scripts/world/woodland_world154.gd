extends "res://scripts/world/woodland_world153.gd"
var sword_contact154 := false
func _sword_manager153() -> Script: return preload("res://scripts/combat/balloon_sword154.gd")
func _title35() -> void: DisplayServer.window_set_title("小白鹅 · 154 · 气球玩具 / 随姿态黏附 / Q弹投影")
func _ready() -> void:
 super._ready()
 while not is_instance_valid(swords153): await get_tree().physics_frame
 if "--sword154" in OS.get_cmdline_user_args(): trial152=true;paper_trial129=false;start_combat()
func _apply_shot_hit(shot: Dictionary,hit: Dictionary) -> void:
 var previous := sword_contact154;sword_contact154=shot.get("sword153",false)
 super._apply_shot_hit(shot,hit);sword_contact154=previous
func sugar_contact(contact: Vector3,direction: Vector3) -> void:
 # A sticky balloon does not shatter into the candy projectile's pink shell.
 if not sword_contact154: super.sugar_contact(contact,direction)
func _step_shots(delta: float) -> void:
 for shot in shots:
  if shot.get("sword153",false): shot.trail_distance=-1000.
 super._step_shots(delta)
