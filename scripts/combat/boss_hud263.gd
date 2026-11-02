extends "res://scripts/combat/boss_hud257.gd"
func _ready() -> void:
 super._ready();remove_child(timer229);timer229.queue_free()
 timer229=preload("res://scripts/combat/red_alert263.gd").new();timer229.battle=battle;add_child(timer229);timer229.hide()
