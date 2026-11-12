extends "res://scripts/combat/boss_hud263.gd"
func _process(delta: float) -> void:
 super._process(delta)
 if battle.ready264 and battle.mode264!="boss":
  header.text="林间空地 · "+battle.loadout_name226
  footer.text="E 打招呼 / 挑战 · C 装配 · F7重试 · F8回到开场 · F6暂停"
