extends "res://scripts/combat/spider_hud171.gd"
func _process(delta: float) -> void:
 super._process(delta)
 if battle.active114 and battle.spider_trial170:
  header.text="织网小蜘蛛 · %d只 · "%battle.spider_count170+battle.BUILDS170[battle.build170].name
  footer.text="网垫直径4.8米/6秒，射散网结可拆 · 丝球可弹反/完美闪避 · 1—9组合 F6单/三只 F7重开 F4纸 F5团团"+(" · 网垫中：移动-25%" if battle.hero.web_left172>0. else "")
