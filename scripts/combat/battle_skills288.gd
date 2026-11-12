extends "res://scripts/combat/battle_skills263.gd"
func step110(delta: float) -> void:
 # The active form already has its own energy bed; omit legacy candy-gun repeats.
 if battle.beam_active288():stream_sound110=1.
 super.step110(delta)
