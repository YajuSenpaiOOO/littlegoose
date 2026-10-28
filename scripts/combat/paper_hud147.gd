extends "res://scripts/combat/paper_hud146.gd"
func _process(delta: float) -> void:
 super._process(delta)
 if battle.paper_trial129:
  header.text+=(" · 随机巡航" if battle.random_planes147 else " · 瞄准投递")
  footer.text="1普通 2蓄力 3分裂 4追踪 5水柱 6直接弹弓 · F8巡航/瞄准 · Q笔记 · F9换组合"
