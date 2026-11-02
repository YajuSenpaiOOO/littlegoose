extends "res://scripts/combat/balance_hud226.gd"
var timer229: Control
func _ready() -> void:
 super._ready();timer229=preload("res://scripts/combat/red_timer229.gd").new();timer229.battle=battle;add_child(timer229);timer229.hide()
