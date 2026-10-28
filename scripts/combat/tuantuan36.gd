extends "res://scripts/combat/tuantuan35.gd"
const OVERSHOOT := .35
const MAX_LUNGE_DISTANCE := 6.2

func _lock_direction(target: Vector2) -> void:
	var vector := target-Vector2(global_position.x,global_position.z)
	attack_direction=vector.normalized() if vector.length()>.001 else attack_direction
	attack_distance=clampf(vector.length()+OVERSHOOT,1.4,MAX_LUNGE_DISTANCE)

func _update_windup_target(target: Vector2) -> void:
	# Track throughout anticipation, including the exact takeoff tick. The
	# lunge itself remains a straight, committed trajectory with no homing.
	_lock_direction(target)
