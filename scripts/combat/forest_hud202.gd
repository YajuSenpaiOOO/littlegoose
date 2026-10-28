extends "res://scripts/combat/spider_hud173.gd"
func _process(delta: float) -> void:
 super._process(delta)
 if battle.context202 and battle.active114:
  header.text="很吓人的森林！ · %d只 · "%battle.spider_count170+battle.BUILDS170[battle.build170].name
  footer.text="丝球可弹反/完美闪避 · 网垫减移动45% · 1—9组合 F6单/三只 F7重开 F2看布景"
