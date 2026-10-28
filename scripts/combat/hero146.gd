extends "res://scripts/combat/hero142.gd"
func movement_speed() -> float:
 var slow := .45 if is_instance_valid(battle) and is_instance_valid(battle.paper_memories146) and battle.paper_memories146.writing146 else 1.
 return super.movement_speed()*slow
