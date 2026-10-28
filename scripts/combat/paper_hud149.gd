extends "res://scripts/combat/paper_hud146.gd"
func _process(delta: float) -> void:
 super._process(delta)
 if battle.paper_trial129:
  header.text+=" · 标记三投"
  footer.text="左键标记/按住连发 · 1普通 2蓄力 3分裂 4射速 5水柱 6直接弹弓 · Q笔记 · F9换组合"
