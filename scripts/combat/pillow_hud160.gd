extends "res://scripts/combat/paper_hud153.gd"
func _process(delta: float) -> void:
 super._process(delta)
 if battle.active114 and (battle.trial152 or battle.paper_trial129):
  header.text=("作业纸" if battle.paper_trial129 else "团团怪")+" · "+battle.BUILDS160[battle.build160].name
  footer.text="F4纸怪 F5团团 · 1弹弓窝 2飞机窝 3剑雨窝 4分裂窝 5快剑窝 6弹弓 7飞机 8剑雨 9普通窝 · 右键搭窝 Q笔记"
