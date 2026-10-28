extends "res://scripts/combat/paper_hud129.gd"
func _process(delta: float) -> void:
 super._process(delta)
 if not battle.paper_trial129: return
 header.text="作业纸 · %d张 · "%battle.paper_count131+battle.PAPER_BUILDS129[battle.paper_build129]
 footer.text="1 普通 · 2 弹弓 · 3 分裂 · 4 追踪 · F6 六/十张 · F4 重试 · F5 团团 · F3 回院"
