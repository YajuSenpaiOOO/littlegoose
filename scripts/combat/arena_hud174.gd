extends "res://scripts/combat/spider_hud173.gd"
func _process(delta: float) -> void:
 super._process(delta)
 if battle.active114 and battle.spider_trial170 and battle.arena_ready174:
  header.text="独立森林试场 · "+battle.BUILDS170[battle.build170].name
  footer.text="左侧宽外圈 / 右侧近路 · 网垫三块/十秒/移速-45% · F6单/三只 F7重开 1—9组合"
