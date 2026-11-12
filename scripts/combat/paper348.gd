extends "res://scripts/combat/paper347.gd"
func _physics_process(delta: float) -> void:
 if not dead and entry347<=0. and active_ai and not battle.combat_paused and battle.active114 and paper_state129=="drift" and gust_wait130<=delta:
  var feet:=Vector2(position.x,position.z)
  var player:=Vector2(battle.hero.position.x,battle.hero.position.z)
  if feet.distance_to(player)<5.8 and not battle.reserve_dive348(self):
   # Delay the attack clock, not movement or the telegraph of an approved dive.
   gust_wait130=delta+.18
 super._physics_process(delta)
