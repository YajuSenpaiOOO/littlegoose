extends "res://scripts/combat/boss_hud251.gd"
func _process(delta: float) -> void:
 super._process(delta)
 var count=int(battle.max_player_health())
 if gems.gem_count!=count:
  gems.setup(count,420.);gems.set_value(battle.player_hp,battle.max_player_health())
