extends "res://scripts/combat/balance_hud229.gd"
func _process(delta: float) -> void:
 super._process(delta)
 if battle.ready251:
  health_text.text="决心 %s / %s"%[String.num(battle.player_hp,1),String.num(battle.max_player_health(),0)]
  header.text="团团Boss · "+battle.loadout_name226
  footer.text="C 装配与统计 · F7重开 · F6暂停 · F4瞄准模式 · F10落地圈对照 · F3回院"
