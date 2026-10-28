extends "res://scripts/combat/pillow_hud160.gd"
func _process(delta: float) -> void:
 super._process(delta)
 if battle.active114 and (battle.trial152 or battle.paper_trial129):
  header.text=("作业纸" if battle.paper_trial129 else "团团怪")+" · "+battle.BUILDS161[battle.build161].name
  footer.text="Q主角时刻／笔记 · 1直射 2飞机 3剑雨 4弹弓窝 5剑雨窝 6笔记 7飞机笔记 8剑雨笔记 9分裂 · F4纸 F5团团"
