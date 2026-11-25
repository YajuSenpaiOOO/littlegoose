extends "res://scripts/combat/flight_visual386.gd"
func _ready() -> void:
 super._ready();pose386=preload("res://scripts/combat/attack_pose387.gd").new()
func trigger_held386() -> bool:return battle.held387
