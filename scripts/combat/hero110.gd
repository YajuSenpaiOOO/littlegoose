extends "res://scripts/combat/hero109.gd"
func movement_speed() -> float:
 var count: int=battle.buffs.level("paper_racer") if is_instance_valid(battle) else 0
 return super.movement_speed()*(1. if count==0 else (1.3 if count==1 else 1.56))
