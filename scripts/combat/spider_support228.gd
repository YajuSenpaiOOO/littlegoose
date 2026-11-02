extends "res://scripts/combat/spider_support227.gd"
func prepare170(player: Vector2) -> void:
 if not battle.can_weave228():enter170("watch");wait170=.4;return
 super.prepare170(player)
 if state170=="weave":battle.event228("web_start")
