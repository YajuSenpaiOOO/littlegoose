extends "res://scripts/combat/hud37/encounter_hud.gd"
func show_result() -> void:
 super.show_result()
 result_stats.text=result_stats.text.replace(" / 6", " / "+str(battle.total_enemies))
func _process(delta: float) -> void:
 super._process(delta)
 action_text.text="Shift 闪避     右键按住蹲防 · 按下瞬间弹反"
 if battle.hero.get("guarding109")==true:
  fills.y=1. if battle.hero.can_parry() else .20;ready_pop.y=0.
  action_text.text="抱头蹲防 · 减伤40% · 松开后开始冷却"
 if battle.has_method("wave_count110"):
  header.text=header.text.replace(" / 3 "," / %d "%battle.wave_count110())

  if battle.between_left>0. and battle.round_index+1<battle.wave_count110(): header.text="喘口气 · 下一幕 %d 只"%battle.count_for110(battle.round_index+1)
