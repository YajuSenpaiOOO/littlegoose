extends "res://scripts/combat/tuantuan24.gd"
var juice_next_msec := 0

func receive_hit(damage: float,direction: Vector3) -> void:
	# The old splash cooldown is 110 real milliseconds, including during slow-mo.
	var now := Time.get_ticks_msec()
	juice_gate=0. if now>=juice_next_msec else 1.
	var splash := not dead and (now>=juice_next_msec or hp<=damage)
	super.receive_hit(damage,direction)
	if splash: juice_next_msec=now+110

func _ready() -> void:
	super._ready()
	# The fixed horizontal camera already faces this card. Preserve the authored
	# defeat roll instead of letting a billboard shader replace its orientation.
	visual.billboard=BaseMaterial3D.BILLBOARD_DISABLED
