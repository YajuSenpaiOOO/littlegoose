extends "res://scripts/combat/goose385.gd"
func flight_visual_script383() -> Script:return preload("res://scripts/combat/flight_visual386.gd")
func prepare_fire386(target: Vector3) -> void:
 if use_human383 and is_instance_valid(human383):
  human383.face383(target-global_position);human383.emitting386=true
func finish_fire386(emitted: bool, beam := false) -> void:
 if not is_instance_valid(human383):return
 human383.emitting386=false
 if emitted:human383.fired386(beam)
