extends "res://scripts/combat/tuantuan_boss257.gd"
## A successfully returned bounce belongs to the player's parry response.
## It may crash into scenery, but cannot hit the player while leaving overlap.
func deflect(contact: Vector3) -> void:
 var before=parried_count
 super.deflect(contact)
 if parried_count>before:attack_connected=true
func lock247() -> void:
 super.lock247()
 if reflected248:attack_connected=true
func land247() -> void:
 if dead or phase247 not in ["flight","pounce"]:return
 if reflected248:attack_connected=true
 super.land247()
