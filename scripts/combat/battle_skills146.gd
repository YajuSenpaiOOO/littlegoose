extends "res://scripts/combat/battle_skills110.gd"
func step110(delta: float) -> void:
 var saved: int=battle.buffs.level("homework")
 battle.buffs.levels["homework"]=0
 super.step110(delta)
 if saved>0: battle.buffs.levels["homework"]=saved
 else: battle.buffs.levels.erase("homework")
