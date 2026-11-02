extends "res://scripts/combat/tuantuan_minion261.gd"
func _update_windup_target(target: Vector2) -> void:
 # Parent recomputes the unslowed distance every anticipation tick, including takeoff.
 super._update_windup_target(target)
 attack_distance*=clampf(float(get_meta("locomotion_scale153",1.)),.6,1.)
