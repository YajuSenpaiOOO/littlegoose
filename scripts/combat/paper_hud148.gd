extends "res://scripts/combat/paper_hud146.gd"
func _process(delta: float) -> void:
 super._process(delta)
 if battle.paper_trial129:
  header.text+=" · 空中释放"
  footer.text="1普通弹 2蓄力 3分裂 4追踪 5水柱 6直接弹弓 · Q笔记 · F9换组合 · F3回院"
