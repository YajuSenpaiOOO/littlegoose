extends "res://scripts/combat/hud121.gd"
func _process(delta: float) -> void:
 super._process(delta)
 if not battle.paper_trial129: return
 header.text="作业纸独立试演 · "+battle.PAPER_BUILDS129[battle.paper_build129]
 footer.text="1 普通 · 2 弹弓 · 3 分裂 · 4 追踪 · F4 重试纸怪 · F5 团团 · F3 回院"
