extends "res://scripts/combat/spider_hud170.gd"
func _process(delta: float) -> void:
 super._process(delta)
 if battle.active114 and battle.spider_trial170:
  header.text="搓丝团小蜘蛛 · %d只 · "%battle.spider_count170+battle.BUILDS170[battle.build170].name
  footer.text="丝团可射散/绕开 · 1快射 2弹弓 3飞机笔记 4飞机剑 5糖屑舞步 6小窝舞台 7快剑 8住校 9普通 · F6单/三只 F7重开 F4纸 F5团团"
