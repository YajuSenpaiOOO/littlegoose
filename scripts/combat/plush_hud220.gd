extends "res://scripts/combat/squad_hud169.gd"
func _process(delta: float) -> void:
 super._process(delta)
 if battle.get("ready220") and battle.active114:
  header.text="肥猫与玩偶小剧场 · "+battle.BUILDS170[battle.build170].name
  footer.text="肥猫慢追 / 预告滚动可弹反 · 修补时攻击低空蝙蝠 · 1—9组合 F5猪猪开关 F6暂停 F7重开 F2结束"
