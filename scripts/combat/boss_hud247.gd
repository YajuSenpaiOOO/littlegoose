extends "res://scripts/combat/squad_hud169.gd"
func _process(delta: float) -> void:
 super._process(delta)
 if battle.ready247:
  header.text="团团Boss · 弹力三连跳"
  footer.text="1普通 2弹弓 3分裂 4追踪 5气球剑 · F4瞄准模式 · F6暂停 · F7重试 · F3回院"
