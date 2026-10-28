extends "res://scripts/combat/hero110.gd"
func movement_speed() -> float:
 var factor := .60 if is_instance_valid(battle) and battle.charge_active and battle.buffs.level("slingshot")>0 else 1.
 return super.movement_speed()*factor
