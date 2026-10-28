extends "res://scripts/combat/spider_hud171.gd"
func _process(delta: float) -> void:
 super._process(delta)
 if battle.active114 and battle.spider_trial170:
  header.text="脚下织网 · %d只 · "%battle.spider_count170+battle.BUILDS170[battle.build170].name
  footer.text="网垫不可射散 · 直径4.8米/10秒/最多3块 · 1—9组合 F6单/三只 F7重开 F4纸 F5团团"+(" · 丝线绊脚：移速-45%" if battle.hero.web_left172>0. else "")
