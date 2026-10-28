extends "res://scripts/combat/paper_hud129.gd"
func _process(delta: float) -> void:
 super._process(delta)
 if not battle.paper_trial129: return
 header.text="作业纸 · "+str(battle.PAPER_TEST146[battle.paper_build146].name)
 footer.text="1飞机 2弹弓飞机 3分裂飞机 4追踪飞机 5水柱飞机 6直接弹弓 · Q用笔记 · F9轮换 · F3回院"
