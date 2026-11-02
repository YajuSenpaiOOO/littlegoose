extends "res://scripts/combat/boss_hud247.gd"
func _process(delta: float) -> void:
 super._process(delta)
 if battle.ready247:header.text="团团Boss · 急眼连砸 / 弹反反向加弹"
