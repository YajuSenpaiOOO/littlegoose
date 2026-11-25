extends "res://scripts/combat/goose389.gd"
func flight_visual_script383() -> Script:return preload("res://scripts/combat/flight_visual390.gd")
func charged_impulse390(direction: Vector3,ratio: float) -> void:
 if battle.combat_paused:return
 var flat:=Vector3(direction.x,0,direction.z).normalized()
 velocity385=(velocity385-flat*lerpf(1.1,2.3,clampf(ratio,0.,1.))).limit_length(MAX_SPEED385)
