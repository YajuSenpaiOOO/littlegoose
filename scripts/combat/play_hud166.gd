extends "res://scripts/combat/hero_hud161.gd"
func _process(delta: float) -> void:
 super._process(delta)
 if battle.active114 and (battle.trial152 or battle.paper_trial129):
  header.text=("作业纸" if battle.paper_trial129 else "团团怪")+" · "+battle.BUILDS166[battle.build166].name
  footer.text="Shift课间操 · 1分裂快射 2分裂飞机 3分裂剑 4分裂弹弓 5课间操 6直射对照 7二级分裂 8舞台分裂 9小窝舞步 · F4纸 F5团团"
